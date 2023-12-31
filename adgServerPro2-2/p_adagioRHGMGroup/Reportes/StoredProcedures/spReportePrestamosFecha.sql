USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec  Reportes.[spReporteBasicoPrestamosEmpleadoImpresos]  @ClaveEmpleadoInicial = 'ADG0010',@IDTipoPrestamo = '',@IDEstatusPrestamo = '',@IDUsuario=1
CREATE proc [Reportes].[spReportePrestamosFecha] (
	
	@FechaFin date, 
	@TipoNomina varchar(max) = '0', 
	@ClaveEmpleadoInicial Varchar(20) = '0',    
	@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',    
	@Cliente Varchar(max) = '',
	@Departamentos Varchar(max) = '',
	@Sucursales Varchar(max) = '',
	@Puestos Varchar(max) = '',
	@RazonesSociales Varchar(max) = '',
	@RegPatronales Varchar(max) = '',
	@Divisiones Varchar(max) = '',
	@Prestaciones Varchar(max) = '',
	@IDTipoPrestamo varchar(max)		= ''    
	,@IDEstatusPrestamo varchar(max)		= ''    
	,@IDUsuario int
) as
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@dtEmpleados RH.dtEmpleados
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
		,@IDTipoNomina int
		,@IDTipoVigente int
		,@Titulo Varchar(max)    
		,@Prestamos int
		,@IdPrestamo int
	;


	insert into @dtFiltros(Catalogo,Value)
	values('Departamentos',@Departamentos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('RazonesSociales',@RazonesSociales)
		,('RegPatronales',@RegPatronales)
		,('Divisiones',@Divisiones)
		,('Prestaciones',@Prestaciones)
		,('Clientes',@Cliente)


	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))

	SET DATEFIRST 7;  
  
	select top 1 @IDIdioma = dp.Valor  
	from Seguridad.tblUsuarios u with (nolock) 
		Inner join App.tblPreferencias p with (nolock)  
			on u.IDPreferencia = p.IDPreferencia  
		Inner join App.tblDetallePreferencias dp with (nolock)  
			on dp.IDPreferencia = p.IDPreferencia  
		Inner join App.tblCatTiposPreferencias tp with (nolock)  
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia  
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'  
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas with (nolock)  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish' ;  
	end  
    
	SET LANGUAGE @IdiomaSQL; 
	    
	SET @Titulo =  UPPER( 'REPORTE GENERAL DE PRESTAMOS')	
	
	if(@ClaveEmpleadoInicial = '')
		set @ClaveEmpleadoInicial  = '0'
	if(@ClaveEmpleadoFinal = '')
		set @ClaveEmpleadoFinal  = 'ZZZZZZZZZZZZZZZZZZZZ'
		

	insert into @dtEmpleados
	Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario


	update E
		set E.Vigente = M.Vigente
	from RH.tblEmpleadosMaster M  WITH(NOLOCK)
		Inner join @dtEmpleados E
			on M.IDEmpleado = E.IDEmpleado


	IF object_ID('TEMPDB..#TempPrestamosTotal') IS NOT NULL DROP TABLE #TempPrestamosTotal
	DECLARE @TablaPrestamo AS TABLE 
	(	 IDPrestamo int NOT NULL ,
		 Codigo Varchar(50) ,
		 IDPrestamoDetalle int,
		 IdConcepto int,
		 Concepto varchar(50),
		 IdPeriodo int,
		 ClavePeriodo varchar(50),
		 MontoCouta Decimal(4),
		 FechaPago date,
		 Receptor Varchar(50),
		 IDUsuario int,
		 Ususario varchar(50)
	 )
	
	select  ROW_NUMBER() over (order by IDPrestamo) as ID, e.IDEmpleado, p.IDPrestamo, CAST(0.01 as Float) as MontoAlDia, CAST(0.01 as Float) as Saldo
	into #TempPrestamosTotal
	from @dtEmpleados e
	inner join Nomina.tblPrestamos p
		on e.IDEmpleado = p.IDEmpleado
	left join Nomina.tblCatTiposPrestamo tpp
		on tpp.IDTipoPrestamo = p.IDTipoPrestamo
	left join Nomina.tblCatEstatusPrestamo ep
		on ep.IDEstatusPrestamo = p.IDEstatusPrestamo
	where (p.IDTipoPrestamo in ( select item from app.Split( @IDTipoPrestamo,',')) or isnull(@IDTipoPrestamo,'') = '')
	and p.FechaCreacion <= @FechaFin
	
	set @Prestamos = (select MAX( ID) from #TempPrestamosTotal)
	
	--select @Prestamos = 106

	--select * from #TempPrestamosTotal where ID = 89 
	--select * from #TempPrestamosTotal where ID = 106 return
	while (@Prestamos > 0)
	Begin		
		select @IdPrestamo = IdPrestamo from #TempPrestamosTotal where ID = @Prestamos

		insert into @TablaPrestamo
		exec [Nomina].[spBuscarDetallePrestamo] @IDPrestamo=@IdPrestamo
	
		update p set MontoAlDia = isnull((Select SUM(CAST(MontoCouta as FLOAT)) FROM @TablaPrestamo where FechaPago <= @FechaFin),0)
		from #TempPrestamosTotal p
		where p.IDPrestamo = @IdPrestamo

		delete  from @TablaPrestamo

		set @Prestamos = @Prestamos - 1

	end

	update t set saldo = (isnull(p.MontoPrestamo,0) - isnull(t.MontoAlDia,0))
	from #TempPrestamosTotal t
		inner join Nomina.tblprestamos p on p.idprestamo = t.idprestamo

	--select * from #TempPrestamosTotal return

	delete from #TempPrestamosTotal where Saldo <= 0
	
	select 
		e.ClaveEmpleado as Clave
		,e.NOMBRECOMPLETO as Nombre
		,ISNULL(Puesto.Codigo,'000') + ' - ' +e.Puesto as [PUESTO]
		,ISNULL(Depto.Codigo,'000')+' - '+e.Departamento AS [DEPARTAMENTO]
		,ISNULL(Suc.Codigo,'000')+' - '+ e.Sucursal as [SUCURSAL]
		,ISNULL(Div.Codigo,'000') +' - '+ e.Division AS [DIVISION]
		,e.TipoNomina
		,ISNULL(Clientes.Codigo,'000')+' - '+e.Cliente AS [CLIENTE]
		,CASE WHEN e.Vigente = 1 THEN 'SI' ELSE 'NO' END [VIGENTE HOY]
		,tp.Descripcion as TipoPrestacion
		,foto = cg.Valor + e.ClaveEmpleado + '.jpeg'
		,@Titulo as Titulo
		-----------------------
		,p.Codigo as CodigoPrestamo
		,isnull(p.MontoPrestamo,0) as  MontoPrestamo
		,isnull(p.Intereses,0) as Intereses 
		,p.Cuotas
		,p.CantidadCuotas
		,p.FechaCreacion
		,p.FechaInicioPago
		,tpp.Descripcion TipoPrestamo
		,CASE WHEN (p.MontoPrestamo - MontoAldia.MontoAlDia) > 0 THEN 'ACTIVO' else  ep.Descripcion end as EstatusPrestamo
		,(p.MontoPrestamo - MontoAldia.MontoAlDia) as Saldo
		,p.IDPrestamo
		,p.Descripcion as [MOTIVO]
		
	from @dtEmpleados e
		left join RH.tblCatSucursales Suc with (nolock)
			on Suc.IDSucursal = e.IDSucursal
		left join RH.tblCatDepartamentos Depto with (nolock)
			on Depto.IDDepartamento = e.IDDepartamento
		left join RH.tblCatPuestos Puesto with (nolock)
			on Puesto.IDPuesto = E.IDPuesto
		left join RH.tblCatDivisiones Div with(nolock)
			on div.IDDivision = e.IDDivision
		left join RH.tblCatCentroCosto CC with(nolock)
			on CC.IDCentroCosto = e.IDCentroCosto
		left join RH.tblCatClasificacionesCorporativas Clasificacion with(nolock)
			on Clasificacion.IDClasificacionCorporativa = e.IDClasificacionCorporativa
		left join RH.tblCatClientes clientes with(nolock)
			on clientes.IDCliente = e.IDCliente
		left join RH.tblCatTiposPrestaciones tp
			on e.IDTipoPrestacion = tp.IDTipoPrestacion
		left join App.tblConfiguracionesGenerales cg
			on cg.IDConfiguracion = 'PathFotos'
		inner join #TempPrestamosTotal MontoAldia
			on MontoAldia.IDEmpleado = e.IDEmpleado
		inner join Nomina.tblPrestamos p
			on MontoAldia.IDPrestamo = p.IDPrestamo
		left join Nomina.tblCatTiposPrestamo tpp
			on tpp.IDTipoPrestamo = p.IDTipoPrestamo
		left join Nomina.tblCatEstatusPrestamo ep
			on ep.IDEstatusPrestamo = p.IDEstatusPrestamo

	where (p.IDTipoPrestamo in ( select item from app.Split( @IDTipoPrestamo,',')) or isnull(@IDTipoPrestamo,'') = '')
GO
