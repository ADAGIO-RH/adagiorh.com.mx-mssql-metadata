USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarEmpleadosInfonavit] (
	@FechaIni date, 
	@FechaFin date, 
	@TipoVigente varchar(max) = '1',  
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
	@IDUsuario int
)
AS
BEGIN
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
	   ,@UMA Decimal(18,2)
   ;   

	select TOP 1 @UMA = UMA
	from Nomina.tblSalariosMinimos
	ORDER BY Fecha desc

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')   
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

	Declare @dtFiltros [Nomina].[dtFiltrosRH]
			,@dtEmpleados [RH].[dtEmpleados]
			,@IDTipoNomina int
			,@IDTipoVigente int
			,@Titulo VARCHAR(MAX) = UPPER( 'REPORTE DE COLABORADORES CON INFONAVIT DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

	insert into @dtFiltros(Catalogo,Value)
	values('Departamentos',@Departamentos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('RazonesSociales',@RazonesSociales)
		,('RegPatronales',@RegPatronales)
		,('Divisiones',@Divisiones)
		,('Prestaciones',@Prestaciones)
		,('Clientes',@Cliente)

	SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoVigente,'1'),','))

	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)
	if(@IDTipoVigente = 1)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select m.*
			,FechaUltimaBaja = (select top 1 m.Fecha 
								from IMSS.tblMovAfiliatorios m 
									join IMSS.tblCatTipoMovimientos ctm 
										on m.IDTipoMovimiento = ctm.IDTipoMovimiento 
								where IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
								order by m.Fecha desc )
			,@Titulo as Titulo
			,IE.Fecha as FechaCredito
			,IE.NumeroCredito as NumeroCredito
			,TD.Descripcion as TipoDescuento
			,TM.Descripcion as TipoMovimiento
			,IE.ValorDescuento as ValorDescuento
			,CASE WHEN TD.Descripcion = 'Porcentaje'   THEN  (((M.SalarioIntegrado/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Factor de Descuento'   THEN (((@UMA/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Cuota Fija Monetaria'   THEN IE.ValorDescuento    
				 ELSE IE.ValorDescuento    
				 END as DescuentoMensual
		 from @dtEmpleados m
		 	join RH.tblInfonavitEmpleado IE
				on M.IDEmpleado = IE.IDEmpleado
			join RH.tblCatInfonavitTipoDescuento TD
				on TD.IDTipoDescuento = IE.IDTipoDescuento
			join RH.tblCatInfonavitTipoMovimiento TM
				on TM.IDTipoMovimiento = IE.IDTipoMovimiento
		--where IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
		--	or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0'

	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select m.* 
			,FechaUltimaBaja = (select top 1 m.Fecha 
								from IMSS.tblMovAfiliatorios m 
									join IMSS.tblCatTipoMovimientos ctm 
										on m.IDTipoMovimiento = ctm.IDTipoMovimiento 
								where IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
								order by m.Fecha desc )
			,@Titulo as Titulo
			,IE.Fecha as FechaCredito
			,IE.NumeroCredito as NumeroCredito
			,TD.Descripcion as TipoDescuento
			,TM.Descripcion as TipoMovimiento
			,IE.ValorDescuento as ValorDescuento
			,CASE WHEN TD.Descripcion = 'Porcentaje'   THEN  (((M.SalarioIntegrado/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Factor de Descuento'   THEN (((@UMA/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Cuota Fija Monetaria'   THEN IE.ValorDescuento    
				 ELSE IE.ValorDescuento    
				 END as DescuentoMensual
		from RH.tblEmpleadosMaster M
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			join RH.tblInfonavitEmpleado IE
				on M.IDEmpleado = IE.IDEmpleado
			join RH.tblCatInfonavitTipoDescuento TD
				on TD.IDTipoDescuento = IE.IDTipoDescuento
			join RH.tblCatInfonavitTipoMovimiento TM
				on TM.IDTipoMovimiento = IE.IDTipoMovimiento
		where  
		 M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
			or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0'  
		and M.IDEmpleado not in (Select IDEmpleado from @dtEmpleados)
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
		select m.* 
			,FechaUltimaBaja = (select top 1 m.Fecha 
								from IMSS.tblMovAfiliatorios m 
									join IMSS.tblCatTipoMovimientos ctm 
										on m.IDTipoMovimiento = ctm.IDTipoMovimiento 
								where IDEmpleado = m.IDEmpleado and ctm.Codigo = 'B' 
								order by m.Fecha desc )
			,@Titulo as Titulo
			,IE.Fecha as FechaCredito
			,IE.NumeroCredito as NumeroCredito
			,TD.Descripcion as TipoDescuento
			,TM.Descripcion as TipoMovimiento
			,IE.ValorDescuento as ValorDescuento
			,CASE WHEN TD.Descripcion = 'Porcentaje'   THEN  (((M.SalarioIntegrado/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Factor de Descuento'   THEN (((@UMA/100) * IE.ValorDescuento) * 30.4)    
				  WHEN TD.Descripcion = 'Cuota Fija Monetaria'   THEN IE.ValorDescuento    
				 ELSE IE.ValorDescuento    
				 END as DescuentoMensual
		from RH.tblEmpleadosMaster M
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
			join RH.tblInfonavitEmpleado IE
				on M.IDEmpleado = IE.IDEmpleado
			join RH.tblCatInfonavitTipoDescuento TD
				on TD.IDTipoDescuento = IE.IDTipoDescuento
			join RH.tblCatInfonavitTipoMovimiento TM
				on TM.IDTipoMovimiento = IE.IDTipoMovimiento
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
END
GO
