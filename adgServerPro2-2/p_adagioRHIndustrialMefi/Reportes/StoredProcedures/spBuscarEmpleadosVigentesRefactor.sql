USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Reportes].[spBuscarEmpleadosVigentesRefactor] (
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
	@Regiones Varchar(max) = '',
	@ClasificacionesCorporativas Varchar(max) = '',
	@CentrosCostos Varchar(max) = '',
	@Areas Varchar(max) = '',
	@TiposContratacion Varchar(max) = '',
	@IDUsuario int
)
AS
BEGIN

	 DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null;   
	
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
			,@Titulo VARCHAR(MAX) = UPPER( 'REPORTE DE COLABORADORES VIGENTES DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

	insert into @dtFiltros(Catalogo,Value)
	values
		 ('Departamentos',@Departamentos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('RazonesSociales',@RazonesSociales)
		,('RegPatronales',@RegPatronales)
		,('Divisiones',@Divisiones)
		,('Prestaciones',@Prestaciones)
		,('Clientes',@Cliente)
		,('Regiones',@Regiones)
		,('ClasificacionesCorporativas',@ClasificacionesCorporativas)
		,('CentrosCostos',@CentrosCostos)
		,('Areas',@Areas)
		,('TiposContratacion',@TiposContratacion)

	SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END

	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
	SET @IDTipoVigente = (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoVigente,'1'),','))

	--insert into @dtFiltros(Catalogo,Value)
	--values('Clientes',@IDCliente)

	IF ( @ClaveEmpleadoInicial <> 0 )
	BEGIN

			insert into @dtEmpleados
			Exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@IDUsuario=@IDUsuario
   
			SELECT  
				Mast.ClaveEmpleado,
				Mast.NOMBRECOMPLETO as NombreCompleto,
				Mast.FechaAntiguedad,
				Mast.RFC,
				Mast.IMSS,
				Mast.CURP,
				m.SalarioDiario,
				m.SalarioVariable,
				m.SalarioIntegrado,
				m.SalarioDiarioReal,
				CASE WHEN Mast.vigente = 1 THEN 'SI' ELSE 'NO' END as Vigencia,
				@Titulo as Titulo
			

			FROM @dtEmpleados m
				inner join RH.tblEmpleadosMaster Mast with (nolock) on m.IDEmpleado = mast.IDEmpleado
				inner join RH.tblEmpleados em with (nolock) on m.IDEmpleado = em.IDEmpleado
    END

	ELSE IF ( @ClaveEmpleadoInicial = 0 )
		BEGIN

       

		if(@IDTipoVigente = 1)
		BEGIN
			insert into @dtEmpleados
			Exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina,@EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario


            select 
				Mast.ClaveEmpleado,
				Mast.NOMBRECOMPLETO as NombreCompleto,
				Mast.FechaAntiguedad,
				Mast.RFC,
				Mast.IMSS,
				Mast.CURP,
				m.SalarioDiario,
				m.SalarioVariable,
				m.SalarioIntegrado,
				m.SalarioDiarioReal,
				CASE WHEN Mast.vigente = 1 THEN 'SI' ELSE 'NO' END as Vigencia,
				@Titulo as Titulo
			

				from @dtEmpleados m
					inner join RH.tblEmpleadosMaster Mast with (nolock) on m.IDEmpleado = mast.IDEmpleado
					inner join RH.tblEmpleados em with (nolock) on m.IDEmpleado = em.IDEmpleado
					join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on m.IDEmpleado = dfe.IDEmpleado and dfe.IDUsuario = @IDUsuario
					LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) on M.IDTipoPrestacion = TP.IDTipoPrestacion
					left join [RH].[tblEmpleadoPTU] PTU with (nolock) on m.IDEmpleado = PTU.IDEmpleado
					left join RH.tblSaludEmpleado SE with (nolock) on SE.IDEmpleado = M.IDEmpleado
					left join RH.tblDireccionEmpleado direccion with (nolock) on direccion.IDEmpleado = M.IDEmpleado
						AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
					left join SAT.tblCatColonias c with (nolock) on direccion.IDColonia = c.IDColonia
					left join SAT.tblCatMunicipios Muni with (nolock) on muni.IDMunicipio = direccion.IDMunicipio
					left join SAT.tblCatEstados EST with (nolock) on EST.IDEstado = direccion.IDEstado 
					left join SAT.tblCatLocalidades localidades with (nolock) on localidades.IDLocalidad = direccion.IDLocalidad 
					left join SAT.tblCatCodigosPostales CP with (nolock) on CP.IDCodigoPostal = direccion.IDCodigoPostal
					left join RH.tblCatRutasTransporte rutas with (nolock) on direccion.IDRuta = rutas.IDRuta
					left join RH.tblInfonavitEmpleado Infonavit with (nolock) on Infonavit.IDEmpleado = m.IDEmpleado
						and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
					left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
					left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
					left join RH.tblPagoEmpleado PE with (nolock) on PE.IDEmpleado = M.IDEmpleado
						and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
					left join Nomina.tblLayoutPago LP with (nolock) on LP.IDLayoutPago = PE.IDLayoutPago
							and LP.IDConcepto = PE.IDConcepto
					left join SAT.tblCatBancos bancos with (nolock) on bancos.IDBanco = PE.IDBanco
					--left join RH.tblTipoTrabajadorEmpleado TTE
					--	on TTE.IDEmpleado = m.IDEmpleado
					left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
								from RH.tblTipoTrabajadorEmpleado with (nolock)  
							) as TTE on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
					left join IMSS.tblCatTipoTrabajador TT with (nolock) on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
					left join SAT.tblCatTiposContrato TC with (nolock) on TC.IDTipoContrato = TTE.IDTipoContrato
					--left join ##tempDatosExtraEmpleados deex on deex.[No. Sys] = m.IDEmpleado
					--LEFT JOIN RH.tblContactoEmpleado ce on ce.IDEmpleado = m.IDEmpleado and ce.IDTipoContactoEmpleado = (select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'EMAIL')
				order by M.ClaveEmpleado asc
   
		END


		ELSE IF(@IDTipoVigente = 2)
		BEGIN
			insert into @dtEmpleados
			exec [RH].[spBuscarEmpleados] @EmpleadoIni=@ClaveEmpleadoInicial,@EmpleadoFin=@ClaveEmpleadoFinal,@FechaIni = @FechaIni, @FechaFin = @FechaFin,@IDTipoNomina=@IDTipoNomina, @dtFiltros = @dtFiltros,@IDUsuario=@IDUsuario
	
	
			SELECT  
				m.ClaveEmpleado,
				m.NOMBRECOMPLETO as NombreCompleto,
				m.FechaAntiguedad,
				m.RFC,
				m.IMSS,
				m.CURP,
				m.SalarioDiario,
				m.SalarioVariable,
				m.SalarioIntegrado,
				m.SalarioDiarioReal,
				CASE WHEN m.vigente = 1 THEN 'SI' ELSE 'NO' END as Vigencia,
				@Titulo as Titulo
		
			from RH.tblEmpleadosMaster M with (nolock)
				inner join RH.tblEmpleados em with (nolock) on m.IDEmpleado = em.IDEmpleado 
				Left join @dtEmpleados e on e.IDEmpleado = M.IDEmpleado -- El IDEMPLEADO NULL son los NO vigentes
			Where e.IDEmpleado is null and ---- El IDEMPLEADO NULL son los NO vigentes 
			( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
					or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
			   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
					or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))            
			   and  ((M.IDCentroCosto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),','))             
				   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'CentrosCostos' and isnull(Value,'')<>''))))
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
			and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
				 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
			   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
				 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))              
				and ((M.IDRegion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Regiones' and isnull(Value,'')<>''))) 
				 and ((M.IDArea in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Areas' and isnull(Value,'')<>''))) 
			   and ((            
				((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
					) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
					order by M.ClaveEmpleado asc
		END	

		ELSE IF(@IDTipoVigente = 3)
		BEGIN
		SELECT 
				m.ClaveEmpleado,
				m.NOMBRECOMPLETO as NombreCompleto,
				m.FechaAntiguedad,
				m.RFC,
				m.IMSS,
				m.CURP,
				m.SalarioDiario,
				m.SalarioVariable,
				m.SalarioIntegrado,
				m.SalarioDiarioReal,
				CASE WHEN m.vigente = 1 THEN 'SI' ELSE 'NO' END as Vigencia,
				@Titulo as Titulo
		from RH.tblEmpleadosMaster M with (nolock) 
				inner join RH.tblEmpleados em with (nolock) on m.IDEmpleado = em.IDEmpleado
					join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock)  on m.IDEmpleado = dfe.IDEmpleado 
						and dfe.IDUsuario = @IDUsuario
					LEFT JOIN RH.tblCatTiposPrestaciones TP with (nolock) on M.IDTipoPrestacion = TP.IDTipoPrestacion
					left join [RH].[tblEmpleadoPTU] PTU with (nolock) on m.IDEmpleado = PTU.IDEmpleado
					left join RH.tblSaludEmpleado SE with (nolock) on SE.IDEmpleado = M.IDEmpleado
					left join RH.tblDireccionEmpleado direccion with (nolock) on direccion.IDEmpleado = M.IDEmpleado
						AND direccion.FechaIni<= getdate() and direccion.FechaFin >= getdate()   
					left join SAT.tblCatColonias c with (nolock) on direccion.IDColonia = c.IDColonia
					left join SAT.tblCatMunicipios Muni with (nolock) on muni.IDMunicipio = direccion.IDMunicipio
					left join SAT.tblCatEstados EST with (nolock) on EST.IDEstado = direccion.IDEstado 
					left join SAT.tblCatLocalidades localidades with (nolock) on localidades.IDLocalidad = direccion.IDLocalidad 
					left join SAT.tblCatCodigosPostales CP with (nolock) on CP.IDCodigoPostal = direccion.IDCodigoPostal
					left join RH.tblCatRutasTransporte rutas with (nolock) on direccion.IDRuta = rutas.IDRuta
					left join RH.tblInfonavitEmpleado Infonavit with (nolock) on Infonavit.IDEmpleado = m.IDEmpleado
						and Infonavit.fecha<= getdate() and Infonavit.fecha >= getdate()   
					left join RH.tblCatInfonavitTipoDescuento InfonavitTipoDescuento with (nolock) on InfonavitTipoDescuento.IDTipoDescuento = Infonavit.IDTipoDescuento
					left join RH.tblCatInfonavitTipoMovimiento InfonavitTipoMovimiento with (nolock) on InfonavitTipoMovimiento.IDTipoMovimiento = Infonavit.IDTipoMovimiento
					left join RH.tblPagoEmpleado PE with (nolock) on PE.IDEmpleado = M.IDEmpleado
						and PE.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos with (nolock)  where Codigo = '601')
					left join Nomina.tblLayoutPago LP with (nolock) on LP.IDLayoutPago = PE.IDLayoutPago
						and LP.IDConcepto = PE.IDConcepto
					left join SAT.tblCatBancos bancos with (nolock) on bancos.IDBanco = PE.IDBanco
					--left join RH.tblTipoTrabajadorEmpleado TTE
					--	on TTE.IDEmpleado = m.IDEmpleado
					left join (select *,ROW_NUMBER()OVER(PARTITION BY IDEmpleado order by IDTipoTrabajadorEmpleado desc) as [Row]
								from RH.tblTipoTrabajadorEmpleado with (nolock)  
							) as TTE on TTE.IDEmpleado = m.IDEmpleado and TTE.[Row] = 1
					left join IMSS.tblCatTipoTrabajador TT with (nolock) on TTE.IDTipoTrabajador = TT.IDTipoTrabajador
					left join SAT.tblCatTiposContrato TC with (nolock) on TC.IDTipoContrato = TTE.IDTipoContrato
					--left join ##tempDatosExtraEmpleados deex on deex.[No. Sys] = m.IDEmpleado
				Where 
				( M.IDTipoNomina in (Select CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),','))
					or (Select top 1 CAST(ITEM as int) from App.Split(isnull(@TipoNomina,'0'),',')) = '0')  
				   and  ((M.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))             
				   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))
				   and  ((M.IDCentroCosto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'CentrosCostos'),','))             
				   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'CentrosCostos' and isnull(Value,'')<>''))))
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
				 and ((M.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>''))) 
				   and ((M.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))
				 and ((M.IDRegion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Regiones'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Regiones' and isnull(Value,'')<>''))) 
				 and ((M.IDArea in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Areas'),',')))             
					 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Areas' and isnull(Value,'')<>''))) 
					 
				   and ((            
					((COALESCE(M.ClaveEmpleado,'')+' '+ COALESCE(M.Paterno,'')+' '+COALESCE(M.Materno,'')+', '+COALESCE(M.Nombre,'')+' '+COALESCE(M.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')               
						) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))  
						order by M.ClaveEmpleado asc
		END
	END
END
GO
