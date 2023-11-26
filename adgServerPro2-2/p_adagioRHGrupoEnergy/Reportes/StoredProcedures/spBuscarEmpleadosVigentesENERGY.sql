USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarEmpleadosVigentesENERGY] (
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
   ,@IdiomaSQL varchar(100) = null;   
 select top 1 @IDIdioma = dp.Valor        
 from Seguridad.tblUsuarios u        
  Inner join App.tblPreferencias p        
   on u.IDPreferencia = p.IDPreferencia        
  Inner join App.tblDetallePreferencias dp        
   on dp.IDPreferencia = p.IDPreferencia        
  Inner join App.tblCatTiposPreferencias tp        
   on tp.IDTipoPreferencia = dp.IDTipoPreferencia        
 where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'        
        
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
			,@Titulo VARCHAR(MAX) = UPPER( 'REPORTE DE COLABORADORES VIGENTES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))



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
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario


		select m.* ,
            cc.Codigo AS CODIGOCENTROCOSTO,
            cs.Codigo AS CODIGOSUCURSAL,
            cd.Codigo AS CODIGODEPARTAMENTO,
            cp.Codigo AS CODIGOPUESTO
			,FechaUltimaBaja = (select top 1 mov.Fecha 
								from IMSS.tblMovAfiliatorios mov 
									join IMSS.tblCatTipoMovimientos ctm 
										on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
								where IDEmpleado = M.IDEmpleado and ctm.Codigo = 'B' 
								order by mov.Fecha desc )
			,@Titulo as Titulo
			,case when Master.Vigente=1 then 'Si' else 'No' end as Vigencia
		from @dtEmpleados M
			inner join RH.tblEmpleadosMaster Master WITH(NOLOCK)
				on M.IDEmpleado = master.IDEmpleado
            inner join RH.tblCatCentroCosto CC on m.IDCentroCosto=cc.IDCentroCosto
            inner join RH.tblCatSucursales CS on m.IDSucursal=cs.IDSucursal
            inner join RH.tblCatDepartamentos CD on m.IDDepartamento=cd.IDDepartamento
            inner join RH.tblCatPuestos CP on m.IDPuesto=cp.IDPuesto
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
		ORDER BY M.ClaveEmpleado ASC
		--where 
		--( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
		--	or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
		--   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
		--   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
		--   and ((M.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))             
		--	   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))            
		--   and ((M.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))             
		--	  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))            
		--   and ((M.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))            
		--   and ((M.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))         
		--   and ((M.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))        
		--   and ((M.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))      
		--   and ((M.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))      
		-- and ((M.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))     
		--   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
		--	 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))               
		--   and ((            
		--	((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
		--		) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
	END
	ELSE IF(@IDTipoVigente = 2)
	BEGIN
		insert into @dtEmpleados
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario

		select 
            m.*,
			cc.Codigo AS CODIGOCENTROCOSTO,
            cs.Codigo AS CODIGOSUCURSAL,
            cd.Codigo AS CODIGODEPARTAMENTO,
            cp.Codigo AS CODIGOPUESTO,
            FechaUltimaBaja = (select top 1 mov.Fecha 
								from IMSS.tblMovAfiliatorios mov 
									join IMSS.tblCatTipoMovimientos ctm 
										on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
								where IDEmpleado = M.IDEmpleado and ctm.Codigo = 'B' 
								order by mov.Fecha desc )
			,@Titulo as Titulo
			,case when M.Vigente=1 then 'Si' else 'No' end as Vigencia
		from RH.tblEmpleadosMaster M
			join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
            inner join RH.tblCatCentroCosto CC on m.IDCentroCosto=cc.IDCentroCosto
            inner join RH.tblCatSucursales CS on m.IDSucursal=cs.IDSucursal
            inner join RH.tblCatDepartamentos CD on m.IDDepartamento=cd.IDDepartamento
            inner join RH.tblCatPuestos CP on m.IDPuesto=cp.IDPuesto
		where  M.Vigente = 0
		and
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
		select m.*,
        	cc.Codigo AS CODIGOCENTROCOSTO,
            cs.Codigo AS CODIGOSUCURSAL,
            cd.Codigo AS CODIGODEPARTAMENTO,
            cp.Codigo AS CODIGOPUESTO,
			FechaUltimaBaja = (select top 1 mov.Fecha 
								from IMSS.tblMovAfiliatorios mov 
									join IMSS.tblCatTipoMovimientos ctm 
										on mov.IDTipoMovimiento = ctm.IDTipoMovimiento 
								where IDEmpleado = M.IDEmpleado and ctm.Codigo = 'B' 
								order by mov.Fecha desc )
			,@Titulo as Titulo
			,case when M.Vigente=1 then 'Si' else 'No' end as Vigencia
		from RH.tblEmpleadosMaster M
            inner join RH.tblCatCentroCosto CC on m.IDCentroCosto=cc.IDCentroCosto
            inner join RH.tblCatSucursales CS on m.IDSucursal=cs.IDSucursal
            inner join RH.tblCatDepartamentos CD on m.IDDepartamento=cd.IDDepartamento
            inner join RH.tblCatPuestos CP on m.IDPuesto=cp.IDPuesto
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
END
GO
