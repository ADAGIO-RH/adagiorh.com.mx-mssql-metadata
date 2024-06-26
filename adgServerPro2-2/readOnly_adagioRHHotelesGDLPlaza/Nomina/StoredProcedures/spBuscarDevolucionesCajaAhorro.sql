USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las devoluciones de Caja de ahorro
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

[Nomina].[spBuscarDevolucionesCajaAhorro] 
	@IDDevolucionesCajaAhorro = 0
	,@IDCajaAhorro = 1
	,@IDUsuario = 1
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarDevolucionesCajaAhorro](
	@IDDevolucionesCajaAhorro int = 0
	,@IDCajaAhorro int = 0
	,@IDUsuario int
) as
	select 
		dca.IDDevolucionesCajaAhorro
		,dca.IDCajaAhorro
		,e.IDEmpleado
		,e.NOMBRECOMPLETO as Colaborador
		,dca.Monto
		,dca.FechaHora
		,dca.IDPeriodo
		,coalesce(UPPER(p.ClavePeriodo),'')+'-'+coalesce(UPPER(p.Descripcion),'') as Periodo
		,isnull(p.Cerrado,cast(0 as bit)) as Descontado
		,dca.IDUsuario
		,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') as Usuario
		,tn.IDTipoNomina
		,tn.Descripcion as TipoNomina
		,c.IDCliente
		,c.NombreComercial as Cliente
	from Nomina.[tblDevolucionesCajaAhorro] dca with (nolock) 
		join Nomina.tblCajaAhorro ca with (nolock) on dca.IDCajaAhorro = ca.IDCajaAhorro
		join RH.tblEmpleadosMaster e with (nolock) on ca.IDEmpleado = e.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		join Nomina.tblCatPeriodos p with (nolock) on dca.IDPeriodo = p.IDPeriodo
		join Nomina.tblCatTipoNomina tn with (nolock) on p.IDTipoNomina = tn.IDTipoNomina
		join RH.tblCatClientes c with (nolock) on tn.IDCliente = c.IDCliente
		join Seguridad.tblUsuarios u with (nolock) on dca.IDUsuario = u.IDUsuario
	where (dca.IDDevolucionesCajaAhorro = @IDDevolucionesCajaAhorro or @IDDevolucionesCajaAhorro = 0)
		and (dca.IDCajaAhorro = @IDCajaAhorro or @IDCajaAhorro = 0)
GO
