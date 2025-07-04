USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************   
** Descripción  : Insertar/Actualizar dirección empleado  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2018-07-09  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
2018-07-09  Aneudy Abreu  Se agrega el parámetro IDUsuario  
***************************************************************************************************/  
CREATE PROC [RH].[spIUContactoEmpleado](  
     @IDContactoEmpleado int =0  
    ,@IDEmpleado int  
    ,@IDTipoContactoEmpleado int   
    ,@Value varchar(100)  
	,@Predeterminado bit = 0
    ,@IDUsuario int  
) as  
	set @Value = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(isnull(@Value,''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''), CHAR(160), '')))   
  
  	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max),
	@EmailValido bit
	;

	if (@IDTipoContactoEmpleado = -1)
	begin
		select 
			@Predeterminado = 1

		select top 1 @IDTipoContactoEmpleado = IDTipoContacto
		from RH.tblCatTipoContactoEmpleado ctce with (nolock)
		where IDMedioNotificacion = 'email'

	end

	if((select IDMedioNotificacion from RH.tblCatTipoContactoEmpleado where IDTipoContacto = @IDTipoContactoEmpleado) = 'Email')
	BEGIN
		select @EmailValido = [Utilerias].[fsValidarEmail](isnull(@Value,''))

		IF(@EmailValido = 0)
		BEGIN
			EXEC app.spObtenerError @IDUsuario = @IDUsuario, @codigoError = '0000011', @customMessage = @value
			RETURN;
		END
	END



    if (@IDContactoEmpleado = 0)  
    begin  


		insert into [RH].[tblContactoEmpleado] (IDEmpleado,IDTipoContactoEmpleado,[Value], Predeterminado)  
		select @IDEmpleado,@IDTipoContactoEmpleado,@Value,@Predeterminado
  
		select @IDContactoEmpleado=@@IDENTITY  

		select @NewJSON = a.JSON from [RH].[tblContactoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDContactoEmpleado=@IDContactoEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblContactoEmpleado]','[RH].[spIUContactoEmpleado]','INSERT',@NewJSON,''

    end else  
    begin  
		select @OldJSON = a.JSON from [RH].[tblContactoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDContactoEmpleado=@IDContactoEmpleado


		update [RH].[tblContactoEmpleado]  
			set 
				IDTipoContactoEmpleado= @IDTipoContactoEmpleado  
				,Value=@Value
				,Predeterminado =  @Predeterminado
		where IDContactoEmpleado=@IDContactoEmpleado and IDEmpleado=@IDEmpleado  

		select @NewJSON = a.JSON from [RH].[tblContactoEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDContactoEmpleado=@IDContactoEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblContactoEmpleado]','[RH].[spIUContactoEmpleado]','UPDATE',@NewJSON,@OldJSON
    end;  
      
    exec [RH].[spBuscarContactoEmpleado] @IDContactoEmpleado =@IDContactoEmpleado, @IDUsuario=@IDUsuario  

	declare @tran int 
	set @tran = @@TRANCOUNT
	if(@tran = 0)
	BEGIN
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  
	END
GO
