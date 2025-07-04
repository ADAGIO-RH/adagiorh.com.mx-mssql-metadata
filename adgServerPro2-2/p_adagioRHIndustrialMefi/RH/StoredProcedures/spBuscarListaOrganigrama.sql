USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc RH.spBuscarListaOrganigrama(
	@IDEmpleado int = 0
	,@IDUsuario int 
)
as
declare  
 	 @dtInfoOrganigrama RH.dtInfoOrganigrama
	;

	if (@IDEmpleado = 0)
		select @IDEmpleado = u.IDEmpleado from Seguridad.tblUsuarios u with (nolock) where u.IDUsuario = @IDUsuario

	-- SUPERVISORES
	exec [RH].[spBuscarInfoOrganigramaEmpleado]  
			@IDEmpleado = @IDEmpleado    
			,@IDTipoRelacion = 1 
			,@IDUsuario = @IDUsuario 

	-- SUBORDINADOS
	exec [RH].[spBuscarInfoOrganigramaEmpleado]  
			@IDEmpleado = @IDEmpleado    
			,@IDTipoRelacion = 2 
			,@IDUsuario = @IDUsuario 

	-- COLEGAS
	exec [RH].[spBuscarInfoOrganigramaEmpleado]  
			@IDEmpleado = @IDEmpleado    
			,@IDTipoRelacion = 3 
			,@IDUsuario = @IDUsuario
GO
