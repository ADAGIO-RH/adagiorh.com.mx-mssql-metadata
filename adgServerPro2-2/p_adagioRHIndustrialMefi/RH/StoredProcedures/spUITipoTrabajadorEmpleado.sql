USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec Utilerias.spBuscarSQLObjectsFilter @Filter='spUITipoTrabajadorEmpleado'
--GO

/****************************************************************************************************
** Descripción     : Procedimiento que crea el tipo de trabajor del empleado
** Autor           : Jose Roman
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-10-15
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------
2024-10-15			JOSE ROMAN		SE MODIFICA PROCEDIMIENTO PARA CUANDO NO LLEGUE EL TIPO DE PENSION 
									LE ASIGNE AUTOMATICAMENTE EL TIPO "SIN PENSION"
***************************************************************************************************/


CREATE PROCEDURE [RH].[spUITipoTrabajadorEmpleado]  --30367,null,null,null,null,1
(  
	@IDEmpleado int  
	,@IDTipoTrabajador int   
	,@IDTipoContrato int   
	,@IDTipoSalario int = null   
	,@IDTipoPension int = null
	,@IDUsuario int
)  
AS  
BEGIN  
    Declare @msj nvarchar(max),
	@IDTipoPensionSinPension int
	;  
  
  	 DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


		select @IDTipoPensionSinPension = IDTipoPension 
		from IMSS.tblCatTipoPension with(nolock) 
		where Codigo = '0' --SIN PENSION
	

    IF(ISNULL(@IDTipoTrabajador,0) = 0)  
    BEGIN  
		RETURN;  
    END  
 
	SET @IDTipoSalario = CASE WHEN @IDTipoSalario = 0 THEN NULL ELSE @IDTipoSalario END
	SET @IDTipoPension = CASE WHEN @IDTipoPension = 0 THEN NULL ELSE @IDTipoPension END

	if exists(
		select 1 
		from RH.tblTipoTrabajadorEmpleado  
		where IDEmpleado = @IDEmpleado
	)  
	begin  
		select @OldJSON = a.JSON from [RH].[tblTipoTrabajadorEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

		UPDATE RH.tblTipoTrabajadorEmpleado  
		SET IDTipoTrabajador = @IDTipoTrabajador,
			IDTipoContrato = CASE WHEN ISNULL(@IDTipoContrato,0) = 0 THEN NULL ELSE @IDTipoContrato END,
			IDTipoSalario = @IDTipoSalario,
			IDTipoPension = CASE WHEN ISNULL(@IDTipoPension, @IDTipoPensionSinPension) = 0 THEN @IDTipoPensionSinPension ELSE ISNULL(@IDTipoPension, @IDTipoPensionSinPension) END
		WHERE IDEmpleado = @IDEmpleado  

		select @NewJSON = a.JSON from [RH].[tblTipoTrabajadorEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblTipoTrabajadorEmpleado]','[RH].[spUITipoTrabajadorEmpleado]','UPDATE',@NewJSON,@OldJSON
	end
	else
	BEGIN
		INSERT INTO RH.tblTipoTrabajadorEmpleado(IDEmpleado,IDTipoTrabajador,IDTipoContrato, IDTipoSalario,IDTipoPension)  
		VALUES(@IDEmpleado,@IDTipoTrabajador,CASE WHEN ISNULL(@IDTipoContrato,0) = 0 THEN NULL ELSE @IDTipoContrato END, @IDTipoSalario,CASE WHEN ISNULL(@IDTipoPension, @IDTipoPensionSinPension) = 0 THEN @IDTipoPensionSinPension ELSE ISNULL(@IDTipoPension, @IDTipoPensionSinPension) END) 

		select @NewJSON = a.JSON from [RH].[tblTipoTrabajadorEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado = @IDEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblTipoTrabajadorEmpleado]','[RH].[spUITipoTrabajadorEmpleado]','INSERT',@NewJSON,''
	END 
  
	declare @tran int 
	set @tran = @@TRANCOUNT
	if(@tran = 0)
	BEGIN
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  
	END
  
END
GO
