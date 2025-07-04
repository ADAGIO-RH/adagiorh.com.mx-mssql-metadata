USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************       
** Descripción  : Procedimiento para Crear/Actualizar los creditos Infonavit      
** Autor   : Jose Roman      
** Email   : jose.roman@adagio.com.mx      
** FechaCreacion : 2018-09-06      
** Paremetros  :                    
****************************************************************************************************      
HISTORIAL DE CAMBIOS      
Fecha(yyyy-mm-dd)	Autor			Comentario      
------------------- ------------------- ------------------------------------------------------------      
2019-09-18			Aneudy Abreu	Se agregó la validación para que no permita registrar dos créditos
									de infonavit activos a un mismo colaborador y también se modificó
									para que solo cree el Historial cuando seá un crédito nuevo.
2024-03-19			Jose Roman		Se agrega validación para insertar un registro de inicio de credito
									en el historial cuando se crea el credito por primera vez.
***************************************************************************************************/      
      
CREATE PROCEDURE [RH].[spIUInfonavitEmpleados]      
(      
 @IDInfonavitEmpleado int = 0      
 ,@IDEmpleado int      
 ,@IDRegPatronal int      
 ,@NumeroCredito varchar(10)      
 ,@IDTipoMovimiento int = null     
 ,@Fecha date      
 ,@IDTipoDescuento int      
 ,@ValorDescuento decimal(18,4)      
 ,@AplicaDisminucion bit = 0      
 ,@IDUsuario int  
)      
AS      
BEGIN      
	 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
	if ( -- Si el crédito es nuevo verifica que el colaborador no tengo otro crédito activo
		(exists (select top 1 1 
				from RH.tblInfonavitEmpleado 
				where IDTipoMovimiento <> 2 and IDEmpleado = @IDEmpleado) 
		and ISNULL(@IDInfonavitEmpleado,0) = 0)

		or 
		-- Si está actualizando el crédito verifica que el colaborador no tengo otro crédito activo
		(exists (select top 1 1 
				from RH.tblInfonavitEmpleado 
				where IDTipoMovimiento <> 2 and IDEmpleado = @IDEmpleado and IDInfonavitEmpleado <> ISNULL(@IDInfonavitEmpleado,0))
		and ISNULL(@IDTipoDescuento,0) = 2)
		)
	begin
		raiserror('El colaborador solo puede un Crédito de infonavit activo.',16,1)
		return
	end;

	--RH.TblCatInfonavitTipoMovimiento
	if(@IDInfonavitEmpleado = 0)      
	BEGIN      
		insert into RH.tblInfonavitEmpleado(IDEmpleado,IDRegPatronal,NumeroCredito,IDTipoMovimiento,Fecha,IDTipoDescuento,ValorDescuento,AplicaDisminucion)      
		values(@IDEmpleado,@IDRegPatronal,@NumeroCredito,@IDTipoMovimiento,@Fecha,@IDTipoDescuento,@ValorDescuento,@AplicaDisminucion)      

		set @IDInfonavitEmpleado = @@IDENTITY      

		select @NewJSON = a.JSON from [RH].[tblInfonavitEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDInfonavitEmpleado = @IDInfonavitEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblInfonavitEmpleado]','[RH].[spIUInfonavitEmpleados]','INSERT',@NewJSON,''
     
		if(isnull(@IDTipoMovimiento,0) = 1)
		BEGIN
			insert into rh.tblHistorialInfonavitEmpleado(IDInfonavitEmpleado,IDEmpleado,IDRegPatronal,NumeroCredito,IDTipoMovimiento,Fecha,IDTipoDescuento,ValorDescuento,AplicaDisminucion)      
			values (@IDInfonavitEmpleado,@IDEmpleado,@IDRegPatronal,@NumeroCredito,@IDTipoMovimiento,@Fecha,@IDTipoDescuento,@ValorDescuento,@AplicaDisminucion)  
		END
      
		    
	END      
	ELSE      
	BEGIN   
	
		select @OldJSON = a.JSON from [RH].[tblInfonavitEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDInfonavitEmpleado = @IDInfonavitEmpleado
		   
		UPDATE RH.tblInfonavitEmpleado      
			set IDEmpleado = @IDEmpleado      
			,IDRegPatronal = @IDRegPatronal      
			,NumeroCredito = @NumeroCredito      
			,IDTipoMovimiento = @IDTipoMovimiento      
			,Fecha = @Fecha      
			,IDTipoDescuento = @IDTipoDescuento      
			,ValorDescuento = @ValorDescuento      
			,AplicaDisminucion = @AplicaDisminucion      
		WHERE IDInfonavitEmpleado = @IDInfonavitEmpleado   
		
		select @NewJSON = a.JSON from [RH].[tblInfonavitEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDInfonavitEmpleado = @IDInfonavitEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblInfonavitEmpleado]','[RH].[spIUInfonavitEmpleados]','UPDATE',@NewJSON,@OldJSON
        
	END      
      
	exec  RH.spBuscarInfonavitEmpleados @IDInfonavitEmpleado= @IDInfonavitEmpleado , @IDUsuario = @IDUsuario     
END;
GO
