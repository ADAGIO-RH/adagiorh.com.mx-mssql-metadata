USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spBuscarEmpleadosMasivosCredencial](          
	@dtEmpleados  Varchar(MAX),  
	@IDUsuario int = null          
) AS          
BEGIN          
	select             
		em.IDEmpleado            
		,em.ClaveEmpleado            
		,em.NOMBRECOMPLETO       
		,isnull(em.Nombre, '') as Nombre    
		,isnull(em.SegundoNombre, '') as SegundoNombre           
		,isnull(em.Paterno, '') as Paterno     
		,isnull(em.Materno, '') as Materno     
		,em.Puesto            
		,em.Departamento            
		,em.Sucursal            
		,em.IMSS          
		,em.RFC          
		,em.CURP   
		,em.FechaAntiguedad         
		,em.FechaIngreso                
		,FBE.NombreCompleto NombreEmergencia          
		,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono          
		--,cg.Valor + em.ClaveEmpleado+'.jpg' as Foto 
		,case when FT.ClaveEmpleado IS NULL then (REPLACE(cg.Valor,'Empleados/','nofoto.jpg')) else (cg.Valor + em.ClaveEmpleado+'.jpg') END AS Foto
		,substring(UPPER(COALESCE(EMP.Calle,'')+' '+COALESCE(EMP.Exterior,'')+' '+COALESCE(EMP.Interior,'')+' '+COALESCE(c.NombreAsentamiento,'')),1,49 ) AS Direccion                
		,empresa.NombreComercial as RazonSocial   
		,em.centrocosto as CentroCosto
	from RH.tblEmpleadosMaster em with (nolock)  
		left join RH.tblFotosEmpleados FT with (nolock) on EM.IDEmpleado = FT.IDEmpleado
		left join RH.tblDireccionEmpleado EMP with (nolock) on EMP.IDEmpleado = EM.IDEmpleado  
			and EMP.FechaIni<= getdate() and EMP.FechaFin >= getdate()     
		left join RH.tblEmpresa empresa with (nolock) on empresa.IdEmpresa = em.IDEmpresa    
		left join Sat.tblCatColonias c with (nolock) on EMP.IDColonia = c.IDColonia  
		left join Sat.tblCatMunicipios Muni with (nolock) on muni.IDMunicipio = EMP.IDMunicipio  
		left join Sat.tblCatEstados EST with (nolock) on EST.IDEstado = EMP.IDEstado        
		left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU with (nolock) on EM.IDEmpleado = FEU.IDEmpleado and FEU.IDUsuario = @IDUsuario         
		left join RH.TblFamiliaresBenificiariosEmpleados FBE with (nolock) on FBE.IDEmpleado = EM.IDEmpleado and FBE.Emergencia = 1          
		Cross Apply App.tblConfiguracionesGenerales cg with (nolock)          
	where EM.IDEmpleado in ((select item from App.Split(@dtEmpleados,',')))	and cg.IDConfiguracion = 'PathFotos'  
		and isnull(em.Vigente,0) = 1     
	order by EM.ClaveEmpleado asc  
END
GO
