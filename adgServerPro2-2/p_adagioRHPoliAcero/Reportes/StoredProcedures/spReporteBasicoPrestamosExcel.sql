USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec  Reportes.[spReporteBasicoPrestamosEmpleadoImpresos]  @ClaveEmpleadoInicial = 'ADG0010',@IDTipoPrestamo = '',@IDEstatusPrestamo = '',@IDUsuario=1
CREATE proc [Reportes].[spReporteBasicoPrestamosExcel] (
	
	-- @FechaIni date, 
	-- @FechaFin date, 
	-- @TipoVigente varchar(max) = '1',  
	-- @TipoNomina varchar(max) = '0', 
	-- @ClaveEmpleadoInicial Varchar(20) = '0',    
	-- @ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',    
	-- @Cliente Varchar(max) = '',
	-- @Departamentos Varchar(max) = '',
	-- @Sucursales Varchar(max) = '',
	-- @Puestos Varchar(max) = '',
	-- @RazonesSociales Varchar(max) = '',
	-- @RegPatronales Varchar(max) = '',
	-- @Divisiones Varchar(max) = '',
	-- @Prestaciones Varchar(max) = '',
	-- @IDTipoPrestamo varchar(max)		= ''    
	-- ,@IDEstatusPrestamo varchar(max)		= ''    
	-- ,@IDUsuario int
	@dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int

) as
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	--declare 
	--	@FechaIni date =  '2019-08-01'
	--	,@FechaFin date = '2019-08-15'
	--	,@IDUsuario int = 1
	--;

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@dtEmpleados RH.dtEmpleados
		,@IDTipoNomina int--Listo
        ,@IDTipoVigente int--listo
        ,@FechaIni date--Listo
	    ,@FechaFin date--Listo
        ,@TipoVigente varchar(max) = '1'--Listo
        ,@ClaveEmpleadoInicial Varchar(20) = '0'
        ,@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ'
        ,@Cliente Varchar(max) = ''--Listo
        ,@Departamentos Varchar(max) = ''--Listo
        ,@Sucursales Varchar(max) = ''--Listo
        , @Puestos Varchar(max) = ''--Listo
        ,@RazonesSociales Varchar(max) = ''--Listo
        ,@RegPatronales Varchar(max) = ''--Listo
        ,@Divisiones Varchar(max) = ''--Listo
        ,@Prestaciones Varchar(max) = ''--Listo
        ,@IDTipoPrestamo varchar(max)= ''--Listo
        ,@IDEstatusPrestamo varchar(max)= ''--Listo
        ,@TipoNomina varchar(max) = '0'
        ,@Titulo VARCHAR(MAX) 
        
	;


    select @IDTipoNomina = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoNomina'
    
    select @FechaIni = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '1900-01-01' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaIni'
	
    select @FechaFin = CAST(CASE WHEN ISNULL(Value,'') = '' THEN '9999-12-31' ELSE  Value END as date)
		from @dtFiltros where Catalogo = 'FechaFin'

    select @TipoVigente = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'TipoVigente'    
    
    select @Cliente = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'Cliente'

    select @Departamentos = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'Departamentos'    

    select @Sucursales = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'Sucursales'

    select @Puestos = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'Puestos'

    select @RazonesSociales = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'RazonesSociales'

    select @RegPatronales = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'RegPatronales'

    select @Divisiones = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
		from @dtFiltros where Catalogo = 'Divisiones'

    select @Prestaciones = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	    from @dtFiltros where Catalogo = 'Prestacionefpuestoss' 

    select @IDTipoPrestamo = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	    from @dtFiltros where Catalogo = 'IDTipoPrestamo'

    select @IDEstatusPrestamo = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	    from @dtFiltros where Catalogo = 'IDEstatusPrestamo'    


	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoVigente,'1'),','))  

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
	    
	SET @Titulo =  UPPER( 'REPORTE GENERAL DE PRESTAMOS EN EXCEL')		




	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario


	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados

		select m.*
		from RH.tblEmpleadosMaster M with (nolock)
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
		where  
		 (M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0' ) 
		and isnull(M.Vigente,0) = 0
		   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  


	END ELSE IF(@IDTipoVigente = 3)
	BEGIN
		insert into @dtEmpleados

		select m.*
		from RH.tblEmpleadosMaster M
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
		Where 
		( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
			   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
			  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		 and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
			 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		   and ((            
			((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
				) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
	END


	update E
		set E.Vigente = M.Vigente
	from RH.tblEmpleadosMaster M  WITH(NOLOCK)
		Inner join @dtEmpleados E
			on M.IDEmpleado = E.IDEmpleado







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
		,tp.Descripcion AS [TIPO DE PRESTACION]
		-----------------------
		,p.Codigo AS [CODIGO DE PRESTAMO]
		,FORMAT (p.FechaCreacion, 'dd/MM/yyyy ') as [FECHA CREACION]
        ,FORMAT (p.FechaInicioPago, 'dd/MM/yyyy ') as [FECHA INICIO PAGO]
		,tpp.Descripcion TipoPrestamo
		,ep.Descripcion EstatusPrestamo
        ,isnull(p.MontoPrestamo,0) AS [MONTO DE PRESTAMO]
		,isnull(p.Intereses,0) as INTERESES
		,p.Cuotas
		,p.CantidadCuotas		
		,(isnull(p.MontoPrestamo,0) + isnull(p.Intereses,0))  - isnull((select SUM(MontoCuota) from Nomina.fnPagosPrestamo(p.IDPrestamo)),0) as SALDO
	--	,p.IDPrestamo		
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
		inner join Nomina.tblPrestamos p
			on e.IDEmpleado = p.IDEmpleado
		left join Nomina.tblCatTiposPrestamo tpp
			on tpp.IDTipoPrestamo = p.IDTipoPrestamo
		left join Nomina.tblCatEstatusPrestamo ep
			on ep.IDEstatusPrestamo = p.IDEstatusPrestamo

	where (p.IDTipoPrestamo in ( select item from app.Split( @IDTipoPrestamo,',')) or isnull(@IDTipoPrestamo,'') = '')
	and(p.IDEstatusPrestamo in ( select item from app.Split( @IDEstatusPrestamo,',')) or isnull(@IDEstatusPrestamo,'') = '')
GO
