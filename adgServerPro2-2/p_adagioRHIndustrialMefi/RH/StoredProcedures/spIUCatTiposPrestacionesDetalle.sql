USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatTiposPrestacionesDetalle]
(
	@IDTipoPrestacionDetalle int = 0
	,@IDTipoPrestacion int
	,@Antiguedad int
	,@DiasAguinaldo int
	,@DiasVacaciones int
	,@PrimaVacacional float
	,@PorcentajeExtra float
	,@DiasExtras int
	,@Factor float
	,@IDUsuario int
)
AS
BEGIN

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF (@IDTipoPrestacionDetalle = 0 or @IDTipoPrestacionDetalle is null)
	BEGIN

		INSERT INTO [RH].[tblCatTiposPrestacionesDetalle]
				   (
					IDTipoPrestacion
					,Antiguedad
					,DiasAguinaldo
					,DiasVacaciones
					,PrimaVacacional
					,PorcentajeExtra
					,DiasExtras
					--,Factor
				
				   )
			 VALUES
				   (
				    @IDTipoPrestacion
					,@Antiguedad
					,@DiasAguinaldo
					,@DiasVacaciones
					,@PrimaVacacional
					,@PorcentajeExtra
					,@DiasExtras
				--	,@Factor
				
				   )
			SET @IDTipoPrestacionDetalle = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatTiposPrestacionesDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoPrestacionDetalle = @IDTipoPrestacionDetalle

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestacionesDetalle]','[RH].[spIUCatTiposPrestacionesDetalle]','INSERT',@NewJSON,''

        EXEC [Auditoria].[spIAuditoriaVacaciones] 
        @IDUsuario  = @IDUsuario,
	    @Tabla = '[Asistencia].[tblSaldoVacacionesEmpleado]',
	    @Procedimiento = '[RH].[spIUCatTiposPrestacionesDetalle]',
	    @Accion = 'INSERT',
	    @NewData = @NewJSON,
	    @OldData = '',
	    @Mensaje = 'GENERACION DE VACACIONES POR NUEVO DETALLE DE VACACIONES DE PRESTACION',
        @IDTipoPrestacion  = @IDTipoPrestacion
    
    EXEC [Asistencia].[spSchedulerGeneracionVacaciones] @IDTipoPrestacion = @IDTipoPrestacion, @IDUsuario = @IDUsuario

	END
	ELSE
	BEGIN

        DECLARE
        @DiasVacacionesTabla int 
	
		select @OldJSON = a.JSON from [RH].[tblCatTiposPrestacionesDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoPrestacionDetalle = @IDTipoPrestacionDetalle

        select @DiasVacacionesTabla = ISNULL(b.DiasVacaciones,0) from [RH].[tblCatTiposPrestacionesDetalle] b
		WHERE b.IDTipoPrestacionDetalle = @IDTipoPrestacionDetalle


		UPDATE [RH].[tblCatTiposPrestacionesDetalle]
		   SET  Antiguedad = @Antiguedad
				,DiasAguinaldo = @DiasAguinaldo
				,DiasVacaciones = @DiasVacaciones
				,PrimaVacacional = @PrimaVacacional
				,PorcentajeExtra = @PorcentajeExtra
				,DiasExtras = @DiasExtras
				--,Factor = @Factor
		 WHERE [IDTipoPrestacion] = @IDTipoPrestacion
			and [IDTipoPrestacionDetalle] = @IDTipoPrestacionDetalle

		select @NewJSON = a.JSON from [RH].[tblCatTiposPrestacionesDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoPrestacionDetalle = @IDTipoPrestacionDetalle

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestacionesDetalle]','[RH].[spIUCatTiposPrestacionesDetalle]','UPDATE',@NewJSON,@OldJSON


        IF  (@DiasVacaciones <> @DiasVacacionesTabla)
        BEGIN
        
            EXEC [Auditoria].[spIAuditoriaVacaciones] 
            @IDUsuario  = @IDUsuario,
            @Tabla = '[Asistencia].[tblSaldoVacacionesEmpleado]',
            @Procedimiento = '[RH].[spIUCatTiposPrestacionesDetalle]',
            @Accion = 'INSERT',
            @NewData = @NewJSON,
            @OldData = @OldJSON,
            @Mensaje = 'GENERACION DE VACACIONES POR CAMBIO DE DETALLE DE VACACIONES DE PRESTACION',
            @IDTipoPrestacion  = @IDTipoPrestacion

            EXEC [Asistencia].[spSchedulerGeneracionVacaciones] @IDTipoPrestacion = @IDTipoPrestacion, @IDUsuario = @IDUsuario
        END


	END
END
GO
