USE [readOnly_adagioRHHotelesGDLPlaza]
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
	SELECT             
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
		,reg.RegistroPatronal as RegistroPatronal
		,FBE.NombreCompleto NombreEmergencia          
		,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono          
		--,cg.Valor + em.ClaveEmpleado+'.jpg' as Foto 
		,case when FT.ClaveEmpleado IS NULL then (REPLACE(cg.Valor,'Empleados/','nofoto.jpg')) else (cg.Valor + em.ClaveEmpleado+'.jpg') END AS Foto
		,substring(UPPER(COALESCE(EMP.calle,'')+' '+COALESCE(EMP.Exterior,'')+' '+COALESCE(EMP.Interior,'')+' '+COALESCE(c.NombreAsentamiento,'')),1,49 ) AS Direccion                
		,empresa.NombreComercial as RazonSocial   
	FROM rh.tblEmpleadosMaster em with (nolock)  
		left join RH.tblFotosEmpleados FT with (nolock) on EM.IDEmpleado = FT.IDEmpleado
		left join RH.tblDireccionEmpleado EMP with (nolock) on EMP.IDEmpleado = EM.IDEmpleado  
			and EMP.FechaIni<= getdate() and EMP.FechaFin >= getdate()     
		left join rh.tblEmpresa empresa with (nolock) on empresa.IdEmpresa = em.IDEmpresa    
		left join SAT.tblCatColonias c with (nolock) on EMP.IDColonia = c.IDColonia  
		left join SAT.tblCatMunicipios Muni with (nolock) on muni.IDMunicipio = EMP.IDMunicipio  
		left join SAT.tblCatEstados EST with (nolock) on EST.IDEstado = EMP.IDEstado        
		left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU with (nolock) on EM.IDEmpleado = FEU.IDEmpleado and FEU.IDUsuario = @IDUsuario         
		left join RH.TblFamiliaresBenificiariosEmpleados FBE with (nolock) on FBE.IDEmpleado = EM.IDEmpleado and FBE.Emergencia = 1  
		left join RH.tblCatRegPatronal reg on reg.IDRegPatronal = em.IDRegPatronal
		Cross Apply App.tblConfiguracionesGenerales cg with (nolock)          
	where EM.IDEmpleado in ((select Item from app.Split(@dtEmpleados,',')))	and cg.IDConfiguracion = 'PathFotos'     
	ORDER BY EM.ClaveEmpleado asc  
END 
GO
