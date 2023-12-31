USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec  Reportes.[spReporteBasicoPrestamosEmpleadoImpresos]  @ClaveEmpleadoInicial = 'ADG0010',@IDTipoPrestamo = '',@IDEstatusPrestamo = '',@IDUsuario=1
CREATE proc [Reportes].[spReportePrestamosFecha_Excel] (
	
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int
) as
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@dtEmpleados RH.dtEmpleados
		,@IDTipoNominaInt int 
		,@IDTipoNomina int
		,@IDTipoVigente int
		,@Titulo Varchar(max)    
		,@Prestamos int
		,@IdPrestamo int
		,@FechaFin date
		,@IDTipoPrestamo varchar(max)
	;


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
	    
	select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'

		Select @IDTipoPrestamo = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'IDTipoPrestamo'


	insert into @dtEmpleados
	Exec [RH].[spBuscarEmpleados] @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario


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
		e.ClaveEmpleado as [Clave EMPLEADO]
		,e.NOMBRECOMPLETO as [Nombre]
		,e.Empresa as [RAZON SOCIAL]
		,ISNULL(Puesto.Codigo,'000') + ' - ' +e.Puesto as [PUESTO]
		,ISNULL(Depto.Codigo,'000')+' - '+e.Departamento AS [DEPARTAMENTO]
		,ISNULL(Suc.Codigo,'000')+' - '+ e.Sucursal as [SUCURSAL]
		,ISNULL(Div.Codigo,'000') +' - '+ e.Division AS [DIVISION]
		,e.TipoNomina AS [TIPO DE NOMINA]
		,CASE WHEN e.Vigente = 1 THEN 'SI' ELSE 'NO' END [VIGENTE HOY]
		,p.Codigo as [CODIGO PRESTAMO]
		,isnull(p.MontoPrestamo,0) as  [MONTO TOTAL]
		,isnull(p.Intereses,0) as [INTERESES]
		,p.Cuotas [MONTO POR CUOTA]
		,p.CantidadCuotas AS [CANTIDAD CUOTAS]
		,FORMAT(p.FechaCreacion,'dd/MM/yyyy') AS [FECHA DE CREACIÓN]
		,FORMAT(p.FechaInicioPago,'dd/MM/yyyy') AS [FECHA INICIO DE PAGO]
		,tpp.Descripcion AS [TIPO DE PRESTAMO]
		,(p.MontoPrestamo - MontoAldia.MontoAlDia) as Saldo
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
