USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: <Procedure para Guardar - Actualizar los Expedientes Digitales>
** Autor			: 
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
d del documento
***************************************************************************************************/

CREATE PROCEDURE [Reclutamiento].[spIUExpedientesDigitalesCandidato]
(
	  @IDExpedienteDigitalCandidato int = 0 
	 ,@IDCandidato int
     ,@IDExpedienteDigital int
     ,@Name varchar(100)
     ,@ContentType varchar(200)
     ,@PathFile varchar(max)
     ,@Size int	 
	 ,@FechaVencimiento datetime = null
)
AS
BEGIN
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@NombreLocal Varchar(max),
		@OldSize int,
		@CurrentDate datetime = GETDATE(),
		@Caduca bit,
		@FechaVencimientoCalculada datetime,
		@IDPeriodicidad int,
		@PeriodoVigenciaDocumento int
	   ,@ID_PERIODICIDAD_SIN_DEFINIR INT = 1
	   ,@ID_PERIODICIDAD_DIARIA INT = 2
	   ,@ID_PERIODICIDAD_SEMANAL INT = 3
	   ,@ID_PERIODICIDAD_QUINCENAL INT = 4
	   ,@ID_PERIODICIDAD_MENSUAL INT = 5
	   ,@ID_PERIODICIDAD_BIMESTRAL INT = 6
	   ,@ID_PERIODICIDAD_TRIMESTRAL INT = 7
	   ,@ID_PERIODICIDAD_SEMESTRAL INT = 8

		set @NombreLocal = UPPER( cast((SELECT top 1 IDCandidato from Reclutamiento.tblCandidatos where IDCandidato = @IDCandidato) as varchar(100))
							+ '_'
							+(SELECT top 1 Codigo from rh.tblCatExpedientesDigitales where IDExpedienteDigital = @IDExpedienteDigital)
							+'_'
							+(Select top 1 item from app.Split(@Name,'.') order by id asc))
							+'.'+ (Select top 1 item from app.Split(@Name,'.') order by id desc)
		select @Caduca = Caduca,
			   @PeriodoVigenciaDocumento = PeriodoVigenciaDocumento,
			   @IDPeriodicidad = IDPeriodicidad
		from [rh].[tblCatExpedientesDigitales] 
		where IDExpedienteDigital = @IDExpedienteDigital


		select @FechaVencimientoCalculada = (case 
				when @Caduca = 1 and @FechaVencimiento is null THEN
					case
						when @IDPeriodicidad = @ID_PERIODICIDAD_DIARIA THEN dateadd(day, 1*ISNULL(@PeriodoVigenciaDocumento,1), @CurrentDate)
						when @IDPeriodicidad = @ID_PERIODICIDAD_SEMANAL THEN dateadd(week, 1*ISNULL(@PeriodoVigenciaDocumento,1), @CurrentDate)
						when @IDPeriodicidad = @ID_PERIODICIDAD_QUINCENAL then dateadd(week, 2*ISNULL(@PeriodoVigenciaDocumento,1), @CurrentDate)
						when @IDPeriodicidad = @ID_PERIODICIDAD_MENSUAL then dateadd(MONTH, 1*ISNULL(@PeriodoVigenciaDocumento,1), @CurrentDate)
						when @IDPeriodicidad = @ID_PERIODICIDAD_BIMESTRAL then dateadd(MONTH, 2*ISNULL(@PeriodoVigenciaDocumento,1), @CurrentDate)
						when @IDPeriodicidad = @ID_PERIODICIDAD_TRIMESTRAL then dateadd(MONTH, 3*ISNULL(@PeriodoVigenciaDocumento,1), @CurrentDate)
						when @IDPeriodicidad = @ID_PERIODICIDAD_SEMESTRAL then dateadd(MONTH, 5*ISNULL(@PeriodoVigenciaDocumento,1), @CurrentDate)
						else CAST('9999-01-01' as datetime)
					end
				WHEN @Caduca = 1 and @FechaVencimiento IS NOT NULL THEN @FechaVencimiento
				else CAST(null as datetime)
				end)

	IF(@IDExpedienteDigitalCandidato is null OR @IDExpedienteDigitalCandidato = 0)
	BEGIN
	
		INSERT INTO [Reclutamiento].tblExpedienteDigitalCandidato
           ([IDCandidato]
           ,[IDExpedienteDigital]
           ,[Name]
           ,[ContentType]
           ,[PathFile]
		   ,[Size]
		   ,[FechaVencimiento]
		   ,[FechaCreacion])
     VALUES
           (@IDCandidato
           ,@IDExpedienteDigital
           ,@NombreLocal
           ,@ContentType
           ,@PathFile+@NombreLocal
		   ,@Size
		   ,@FechaVencimientoCalculada
		   ,@CurrentDate)
		
		SET @IDExpedienteDigitalCandidato = @@IDENTITY

		SELECT @NewJSON = a.JSON 
		FROM [Reclutamiento].[tblExpedienteDigitalCandidato] b WITH(NOLOCK)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigitalCandidato = @IDExpedienteDigitalCandidato

		-- EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[TblExpedienteDigitalCandidato]','[Reclutamiento].[spIUExpedientesDigitalesCandidato]','INSERT',@NewJSON,''

	END ELSE
	BEGIN
		
		-- SELECT @OldJSON = a.JSON from [Reclutamiento].[TblExpedienteDigitalCandidato] b  WITH(NOLOCK)
		-- Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		-- WHERE b.IDExpedienteDigitalCandidato = @IDExpedienteDigitalCandidato

		select @OldSize = Size from [Reclutamiento].[TblExpedienteDigitalCandidato] WHERE [IDExpedienteDigitalCandidato] = @IDExpedienteDigitalCandidato

		if @Size = 0
		begin
			UPDATE [Reclutamiento].[TblExpedienteDigitalCandidato]
		   SET [IDCandidato] = @IDCandidato
			  ,[IDExpedienteDigital] = @IDExpedienteDigital
			  ,[Name] = @NombreLocal
			  ,[ContentType] = @ContentType
			  ,[PathFile] = @PathFile+@NombreLocal
			  ,[Size] = @Size
			  ,[FechaVencimiento] = @FechaVencimiento
		 WHERE [IDExpedienteDigitalCandidato] = @IDExpedienteDigitalCandidato
		end
		else
		begin
		   UPDATE [Reclutamiento].[TblExpedienteDigitalCandidato]
		   SET [IDCandidato] = @IDCandidato
			  ,[IDExpedienteDigital] = @IDExpedienteDigital
			  ,[Name] = @NombreLocal
			  ,[ContentType] = @ContentType
			  ,[PathFile] = @PathFile+@NombreLocal
			  ,[Size] = @Size
			  ,[FechaVencimiento] = @FechaVencimiento
			  ,[FechaCreacion] = GETDATE()
		 WHERE [IDExpedienteDigitalCandidato] = @IDExpedienteDigitalCandidato
		end
		

		-- select @NewJSON = a.JSON from [Reclutamiento].[TblExpedienteDigitalCandidato] b WITH(NOLOCK)
		-- Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		-- WHERE b.IDExpedienteDigitalCandidato = @IDExpedienteDigitalCandidato

		-- EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[TblExpedienteDigitalCandidato]','[Reclutamiento].[spIUExpedientesDigitalesCandidato]','UPDATE',@NewJSON,@OldJSON
	END

	 Exec [Reclutamiento].[spBuscarExpedientesDigitalesCandidato] @IDExpedienteDigitalCandidato = @IDExpedienteDigitalCandidato ,@IDCandidato=@IDCandidato

END;
GO
