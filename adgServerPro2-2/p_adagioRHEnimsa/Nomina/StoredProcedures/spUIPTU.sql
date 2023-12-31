USE [p_adagioRHEnimsa]
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
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
  
***************************************************************************************************/ 

CREATE PROCEDURE [Nomina].[spUIPTU]
(
	@IDPTU int = 0,
	@IDEmpresa int ,
	@Ejercicio int ,
	@DiasDescontar Varchar(MAx)= null,
	@DescontarEnfermedadGeneral bit = 0,
	@CantidadGanacia decimal(18,2) = 0,
	@CantidadRepartir decimal(18,2) = 0,
	@CantidadPendiente decimal(18,2) = 0,
	@DiasMinimosTrabajados int = 60,
	@EjercicioPago int,
	@IDUsuario int 
)
AS
BEGIN
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUIPTU]',
		@Tabla		varchar(max) = '[Nomina].[tblPTU]',
		@Accion		varchar(20)	= ''
	;

	IF(@IDPTU = 0)
	BEGIN

		IF EXISTS(Select Top 1 1 from Nomina.[tblPTU] where IDEmpresa = @IDEmpresa and Ejercicio = @Ejercicio)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003',@customMessage = 'Ya existe un PTU para esta empresa y Ejercicio.'
			RETURN 0;
		END

		insert into Nomina.tblPTU(IDEmpresa,Ejercicio,DiasDescontar,DescontarEnfermedadGeneral,CantidadGanancia,CantidadRepartir,CantidadPendiente,DiasMinimosTrabajados,EjercicioPago)
		values(@IDEmpresa,@Ejercicio,@DiasDescontar,@DescontarEnfermedadGeneral,@CantidadGanacia,@CantidadRepartir,@CantidadPendiente,@DiasMinimosTrabajados,@EjercicioPago)
		
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
		from [Nomina].tblPTU b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDPTU = @IDPTU

		UPDATE Nomina.tblPTU
			set IDEmpresa = @IDEmpresa,
				Ejercicio = @Ejercicio,
				DiasDescontar = @DiasDescontar,
				DescontarEnfermedadGeneral = @DescontarEnfermedadGeneral,
				CantidadGanancia = @CantidadGanacia,
				CantidadPendiente = @CantidadPendiente,
				CantidadRepartir = @CantidadRepartir,
				DiasMinimosTrabajados = @DiasMinimosTrabajados,
				EjercicioPago = @EjercicioPago
		Where IDPTU = @IDPTU

		select @NewJSON = a.JSON
		from [Nomina].tblPTU b
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
GO
