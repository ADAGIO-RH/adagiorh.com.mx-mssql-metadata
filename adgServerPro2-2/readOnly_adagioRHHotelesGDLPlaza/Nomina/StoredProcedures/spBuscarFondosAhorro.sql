USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBuscarFondosAhorro](
	@IDFondoAhorro int  = 0
	,@IDTipoNomina int = 0
	,@Ejercicio int = 0
	,@IDUsuario int
) as
	select 
		 cfa.IDFondoAhorro
		,c.IDCliente
		,c.NombreComercial as Cliente
		,cfa.IDTipoNomina
		,tn.Descripcion as TipoNomina
		,cfa.Ejercicio
		,cfa.IDPeriodoInicial
		,p.Descripcion as PeriodoInicial
		,isnull(cfa.IDPeriodoFinal,0) as IDPeriodoFinal
		,isnull(pp.Descripcion,'SIN ASIGNAR') as PeriodoFinal
		,isnull(cfa.IDPeriodoPago,0) IDPeriodoPago
		,isnull(ppago.Descripcion,'SIN ASIGNAR') as PeriodoDePago
		,isnull(ppago.Cerrado,cast(0 as bit)) as Pagado
		,isnull(cfa.FechaHora,getdate()) as FechaHora
		,cfa.IDUsuario
		,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') as Usuario
	from Nomina.tblCatFondosAhorro cfa with(nolock)
		join Nomina.tblCatTipoNomina tn with(nolock) on cfa.IDTipoNomina = tn.IDTipoNomina
		join RH.tblCatClientes c with(nolock) on tn.IDCliente = c.IDCliente
		join Nomina.tblCatPeriodos p with(nolock) on cfa.IDPeriodoInicial = p.IDPeriodo
		left join Nomina.tblCatPeriodos pp with(nolock) on cfa.IDPeriodoFinal = pp.IDPeriodo
		left join Nomina.tblCatPeriodos ppago with(nolock) on cfa.IDPeriodoPago = ppago.IDPeriodo
		join Seguridad.tblUsuarios u  with(nolock) on cfa.IDUsuario = u.IDUsuario
	where (cfa.IDFondoAhorro = @IDFondoAhorro or @IDFondoAhorro = 0)
		and (cfa.IDTipoNomina = @IDTipoNomina or @IDTipoNomina = 0)
		and (cfa.Ejercicio = @Ejercicio or @Ejercicio = 0)
GO
