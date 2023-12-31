USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spBuscarEmpleadoCredencialCLOE] --20340      
(      
	@ClaveEmpleadoInicial Varchar(20) = '0',    
	@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',        
	@Departamentos Varchar(max) = '',
	@Sucursales Varchar(max) = '',
	@Puestos Varchar(max) = '',
	@RazonesSociales Varchar(max) = '',
	@RegPatronales Varchar(max) = '',
	@Divisiones Varchar(max) = '',
	@Prestaciones Varchar(max) = '',
	@IDUsuario int = null     
)      
AS      
BEGIN     

Declare @dtFiltros [Nomina].[dtFiltrosRH],    
	    @empleados [RH].[dtEmpleados]   

	insert into @dtFiltros(Catalogo,Value)
	values('Departamentos',@Departamentos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
		,('RazonesSociales',@RazonesSociales)
		,('RegPatronales',@RegPatronales)
		,('Divisiones',@Divisiones)
		,('Prestaciones',@Prestaciones)
    
	SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END 

insert into @empleados    
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni = @ClaveEmpleadoInicial,@EmpleadoFin = @ClaveEmpleadoFinal,@dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario  



SELECT         
   em.IDEmpleado        
  ,em.ClaveEmpleado        
  ,em.NOMBRECOMPLETO        
  ,em.Nombre        
  ,em.SegundoNombre      
  ,ISNULL(em.Nombre,'') + ' ' + ISNULL(em.SegundoNombre,'') AS Nombres  
  ,em.Paterno        
  ,em.Materno  
  ,ISNULL(em.Paterno,'') + ' ' + ISNULL(em.Materno,'') AS Apellidos        
  ,em.Puesto        
  ,em.Departamento        
  ,em.Sucursal        
  ,em.IMSS      
  ,em.RFC      
  ,em.CURP     
  ,em.Empresa     
  ,FBE.NombreCompleto NombreEmergencia      
  ,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono      
  ,cg.Valor + em.ClaveEmpleado+'.jpg' as Foto    
  ,REPLACE(cg.Valor,'Empleados/','nofoto.jpg') as NoFoto  
  ,CASE WHEN SE.TipoSangre IS NULL THEN '' ELSE ('TIPO DE SANGRE: '+SE.TipoSangre) END AS TipoSangre
 
FROM @empleados em  
	inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
		on EM.IDEmpleado = FEU.IDEmpleado
		and FEU.IDUsuario = @IDUsuario   
left join RH.tblSaludEmpleado SE on EM.IDEmpleado = SE.IDEmpleado
left join RH.TblFamiliaresBenificiariosEmpleados FBE      
  on FBE.IDEmpleado = EM.IDEmpleado      
   and FBE.Emergencia = 1      
 Cross Apply App.tblConfiguracionesGenerales cg      
where --EM.IDEmpleado between @IDEmpleadoIni and @IDEmpleadoFIN     and
  cg.IDConfiguracion = 'PathFotos'      
END
GO
