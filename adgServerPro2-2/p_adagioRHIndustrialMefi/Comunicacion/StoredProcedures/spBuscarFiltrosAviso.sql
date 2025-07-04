USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Comunicacion].[spBuscarFiltrosAviso](
	@IDFiltroAviso int = 0
	,@IDAviso int = 0
	,@IDUsuario int = 0	
) as

	DECLARE @IDIdioma VARCHAR(MAX);
	SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');	


	select 
		IDFiltroAviso
		,IDAviso
		,TipoFiltro
		,[Values]
        , CASE 
            WHEN TipoFiltro='Areas' then 
                (SELECT STRING_AGG(areas.Descripcion, ',')  FROM  rh.tblCatArea areas where IDArea in ((Select item from App.Split([Values],','))))        
            WHEN TipoFiltro='CentrosCostos' then 
                (SELECT STRING_AGG(centroCosto.Descripcion, ',')  FROM  rh.tblCatCentroCosto centroCosto where IDCentroCosto in ((Select item from App.Split([Values],','))))        
            WHEN TipoFiltro='ClasificacionesCorporativas' then 
                --(SELECT STRING_AGG(clasiCorp.Descripcion, ',')  FROM  rh.tblCatClasificacionesCorporativas clasiCorp where IDClasificacionCorporativa in ((Select item from App.Split([Values],','))))        
				(SELECT STRING_AGG(JSON_VALUE(clasiCorp.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')), ',')  FROM  rh.tblCatClasificacionesCorporativas clasiCorp where IDClasificacionCorporativa in ((Select item from App.Split([Values],','))))        
            WHEN TipoFiltro='Clientes' then 
                (SELECT STRING_AGG(clientes.NombreComercial, ',')  FROM  rh.tblCatClientes clientes where IDCliente in ((Select item from App.Split([Values],','))))        
            WHEN TipoFiltro='Departamentos' then 
                (SELECT STRING_AGG(departamentos.Descripcion, ',')  FROM  rh.tblCatDepartamentos departamentos where IDDepartamento in ((Select item from App.Split([Values],','))))
            WHEN TipoFiltro='Divisiones' then 
                (SELECT STRING_AGG(divisiones.Descripcion, ',')  FROM  rh.tblCatDivisiones divisiones where IDDivision in ((Select item from App.Split([Values],','))))        
            WHEN TipoFiltro in('Empleados','Excluir Empleado','Solo Vigentes','Excluir Usuarios','Usuarios','Subordinados')   then 
                (SELECT STRING_AGG(empleados.ClaveEmpleado, ',')  FROM  rh.tblEmpleadosMaster empleados where IDEmpleado in ((Select item from App.Split([Values],','))))
            WHEN TipoFiltro in('Excluir Usuarios','Usuarios')   then 
                (SELECT STRING_AGG(usuarios.Cuenta, ',')  FROM  Seguridad.tblUsuarios usuarios where IDEmpleado in ((Select item from App.Split([Values],','))))
            WHEN TipoFiltro='Prestaciones'then 
                (SELECT STRING_AGG(prestaciones.Descripcion, ',')  FROM  rh.tblCatTiposPrestaciones prestaciones where IDTipoPrestacion in ((Select item from App.Split([Values],','))))
            WHEN TipoFiltro='Puestos'then 
                (SELECT STRING_AGG(puestos.Descripcion, ',')  FROM  rh.tblCatPuestos puestos where IDPuesto in ((Select item from App.Split([Values],','))))
            WHEN TipoFiltro='RazonesSociales'then 
                (SELECT STRING_AGG(empresas.NombreComercial, ',')  FROM  rh.tblEmpresa empresas where IdEmpresa in ((Select item from App.Split([Values],','))))
            WHEN TipoFiltro='Regiones'then 
                (SELECT STRING_AGG(regiones.Descripcion, ',')  FROM  rh.tblCatRegiones regiones where IDRegion in ((Select item from App.Split([Values],','))))
            WHEN TipoFiltro='RegPatronales'then 
                (SELECT STRING_AGG(regPatronales.RazonSocial, ',')  FROM  rh.tblCatRegPatronal regPatronales where IDRegPatronal in ((Select item from App.Split([Values],','))))                        
            WHEN TipoFiltro='Sucursales' then 
                (SELECT STRING_AGG(sucursales.Descripcion, ',')  FROM  rh.tblCatSucursales sucursales where IDSucursal in ((Select item from App.Split([Values],','))))            
            WHEN TipoFiltro='TiposContratacion' then 
                (SELECT STRING_AGG(tiposContratos.Descripcion, ',')  FROM  sat.tblCatTiposContrato tiposContratos where IDTipoContrato in ((Select item from App.Split([Values],','))))
            WHEN TipoFiltro='TiposNomina' then 
                (SELECT STRING_AGG(tiposNomina.Descripcion, ',')  FROM  Nomina.tblCatTipoNomina tiposNomina where IDTipoNomina in ((Select item from App.Split([Values],','))))
                
            
          end as DescripcionValues
	from [Comunicacion].[tblFiltrosAvisos] filtros
	where (filtros.IDFiltroAviso = @IDFiltroAviso or @IDFiltroAviso = 0) and (filtros.IDAviso = @IDAviso or @IDAviso = 0)
GO
