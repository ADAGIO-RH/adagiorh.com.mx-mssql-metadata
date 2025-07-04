USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca las cajas de ahorro registradas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-05-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios


[Nomina].[spBuscarCajasAhorro] 
	@IDCajaAhorro	= 0
	,@IDEmpleado	= 1279
	,@IDUsuario		= 1

***************************************************************************************************/
CREATE proc [Nomina].[spBuscarCajasAhorro](
	@IDCajaAhorro int = 0
	,@IDEmpleado int = 0
	,@IDUsuario int
) as
	select	 ca.IDCajaAhorro
			,ca.IDEmpleado
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO as Colaborador
			,e.IDTipoNomina
			,ca.Monto
			,ca.IDEstatus
			,cg.Catalogo as Estatus
	from [Nomina].[tblCajaAhorro] ca
		join [RH].[tblEmpleadosMaster] e on ca.IDEmpleado = e.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		join [App].[tblCatalogosGenerales] cg on ca.IDEstatus = cg.IDCatalogoGeneral and cg.IDTipoCatalogo = 3
	where  (ca.IDCajaAhorro = @IDCajaAhorro or @IDCajaAhorro = 0)
		and (ca.IDEmpleado = @IDEmpleado or @IDEmpleado = 0)
GO
