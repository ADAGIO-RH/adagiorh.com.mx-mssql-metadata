USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spBuscarEmpleadosMasivosCredencial] --4139  ,1  CLAVEEMPLEADO: 10297 IDEMPLEADO: 4139      
(          
 @dtEmpleados  Varchar(MAX),  
 @IDUsuario int = null          
)          
AS          
BEGIN          
SELECT             
          
   em.IDEmpleado            
  ,em.ClaveEmpleado            
  ,em.NOMBRECOMPLETO       
  ,em.Nombre           
  ,em.SegundoNombre           
  ,em.Paterno           
  ,em.Materno           
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
  ,cg.Valor + em.ClaveEmpleado+'.jpg' as Foto   
  ,substring(UPPER(COALESCE(EMP.calle,'')+' '+COALESCE(EMP.Exterior,'')+' '+COALESCE(EMP.Interior,'')+' '+COALESCE(c.NombreAsentamiento,'')),1,49 ) AS Direccion                
  ,empresa.NombreComercial as RazonSocial   
FROM rh.tblEmpleadosMaster em   
left join RH.tblDireccionEmpleado EMP  
 on EMP.IDEmpleado = EM.IDEmpleado  
 AND EMP.FechaIni<= getdate() and EMP.FechaFin >= getdate()     
left join rh.tblEmpresa empresa  
 on empresa.IdEmpresa = em.IDEmpresa    
left join SAT.tblCatColonias c  
 on EMP.IDColonia = c.IDColonia  
left join SAT.tblCatMunicipios Muni  
 on muni.IDMunicipio = EMP.IDMunicipio  
left join SAT.tblCatEstados EST  
 on EST.IDEstado = EMP.IDEstado        
left join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU    
  on EM.IDEmpleado = FEU.IDEmpleado    
  and FEU.IDUsuario = @IDUsuario         
 left join RH.TblFamiliaresBenificiariosEmpleados FBE          
  on FBE.IDEmpleado = EM.IDEmpleado          
   and FBE.Emergencia = 1          
 Cross Apply App.tblConfiguracionesGenerales cg          
where EM.IDEmpleado in ((select Item from app.Split(@dtEmpleados,',')))    
 --and( EM.IDDepartamento in (select Item from app.Split(@dtDepartamentos,',')) or isnull(@dtDepartamentos,'') = '')      
 --and (EM.IDSucursal in (select Item from app.Split(@dtSucursales,',')) or isnull(@dtSucursales,'') = '')      
 --and (EM.IDPuesto in (select Item from app.Split(@dtPuestos,','))   or isnull(@dtPuestos,'') = ''  )  
 and cg.IDConfiguracion = 'PathFotos'     
   
 ORDER BY EM.ClaveEmpleado asc  
        
END
GO
