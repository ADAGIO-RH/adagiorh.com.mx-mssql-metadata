USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************     
** Descripción  : Insertar/Actualizar los PTU's     
** Autor   : Jose Roman   
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-04-30    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd)	Autor			Comentario    
------------------- ------------------- ------------------------------------------------------------    
2021-04-22			ANEUDY ABREU	Se agregaron nuevos campos(
															 TiposIncapacidadesADescontar
															,DescontarIncapacidades
															,IDPeriodo
															,MontoSueldo								
															,MontoDias								
															,FactorSueldo							
															,FactorDias								
															,IDEmpleadoTipoSalarioMensualConfianza	
															,TopeSalarioMensualConfianza				
														)  
***************************************************************************************************/ 

CREATE PROCEDURE [Nomina].[spUIPTU]
(
	@IDPTU int = 0,
	@IDEmpresa int ,
	@Ejercicio int ,
	@ConceptosIntegranSueldo Varchar(max)= null,
	@DiasDescontar Varchar(max)= null,
	@DescontarIncapacidades bit = 0,
	@TiposIncapacidadesADescontar Varchar(20)= null,
	@CantidadGanacia decimal(18,9) = 0,
	@CantidadRepartir decimal(18,9) = 0,
	@CantidadPendiente decimal(18,9) = 0,
	@DiasMinimosTrabajados int = 60,
	--@EjercicioPago int,
	@IDPeriodo int = null,
	@TopeConfianza decimal(18,2) = null,
	@AplicarReforma bit = null,
	@AplicarPTUFinanciero bit = null,
	--@MontoSueldo decimal(18,9) = 0,
	--@MontoDias decimal(18,9) = 0,
	--@FactorSueldo decimal(18,9) = 0,
	--@FactorDias decimal(18,9) = 0,
	@IDUsuario int 
)
AS
BEGIN
	declare 
		@EjercicioPago int,
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUIPTU]',
		@Tabla		varchar(max) = '[Nomina].[tblPTU]',
		@Accion		varchar(20)	= ''
	;

	if (ISNULL(@IDPeriodo, 0) <> 0)
	begin
		select @EjercicioPago = Ejercicio
		from Nomina.tblCatPeriodos
		where IDPeriodo = @IDPeriodo
	end else 
	begin
		set @EjercicioPago = @Ejercicio + 1
	end	

	IF(@IDPTU = 0)
	BEGIN
		IF EXISTS(Select Top 1 1 from Nomina.[tblPTU] where IDEmpresa = @IDEmpresa and Ejercicio = @Ejercicio)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003',@customMessage = 'Ya existe un PTU para esta empresa y Ejercicio.'
			RETURN 0;
		END

		insert into Nomina.tblPTU(IDEmpresa,Ejercicio, ConceptosIntegranSueldo,DiasDescontar,DescontarIncapacidades, TiposIncapacidadesADescontar,CantidadGanancia,CantidadRepartir,CantidadPendiente,DiasMinimosTrabajados,EjercicioPago, IDPeriodo, TopeConfianza, AplicarReforma, AplicarPTUFinanciero)
		values(@IDEmpresa,@Ejercicio, @ConceptosIntegranSueldo,@DiasDescontar,@DescontarIncapacidades, @TiposIncapacidadesADescontar, @CantidadGanacia,@CantidadRepartir,@CantidadPendiente,@DiasMinimosTrabajados,@EjercicioPago, case when isnull(@IDPeriodo,0) = 0 then null else @IDPeriodo end, @TopeConfianza, isnull(@AplicarReforma,0), isnull(@AplicarPTUFinanciero,0))
		
		set @IDPTU = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].tblPTU b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDPTU = @IDPTU
	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].tblPTU b with (nolock)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDPTU = @IDPTU

		UPDATE Nomina.tblPTU
			set IDEmpresa						= @IDEmpresa,
				Ejercicio						= @Ejercicio,
				ConceptosIntegranSueldo			= @ConceptosIntegranSueldo,
				DiasDescontar					= @DiasDescontar,
				DescontarIncapacidades			= @DescontarIncapacidades,
				TiposIncapacidadesADescontar	= @TiposIncapacidadesADescontar,
				CantidadGanancia				= @CantidadGanacia,
				CantidadPendiente				= @CantidadPendiente,
				CantidadRepartir				= @CantidadRepartir,
				DiasMinimosTrabajados			= @DiasMinimosTrabajados,
				EjercicioPago					= @EjercicioPago,
				IDPeriodo						=  case when isnull(@IDPeriodo,0) = 0 then null else @IDPeriodo end,
				TopeConfianza					= @TopeConfianza,
				AplicarReforma					= isnull(@AplicarReforma,0),
				AplicarPTUFinanciero			= isnull(@AplicarPTUFinanciero,0)
		Where IDPTU = @IDPTU

		select @NewJSON = a.JSON
		from [Nomina].tblPTU b with (nolock)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDPTU = @IDPTU
	END

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

	Exec Nomina.spBuscarPTU @IDPTU
END


--update Nomina.tblPTU
--set TiposIncapacidadesADescontar = ''
GO
