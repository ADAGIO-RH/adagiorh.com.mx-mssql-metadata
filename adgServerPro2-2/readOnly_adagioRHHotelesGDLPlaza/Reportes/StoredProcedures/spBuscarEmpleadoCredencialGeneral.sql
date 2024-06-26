USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spBuscarEmpleadoCredencialGeneral] --20340      
(      
	@ClaveEmpleadoInicial Varchar(20) = '0',    
	@ClaveEmpleadoFinal Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',        
	@Departamentos Varchar(max) =null,
	@Sucursales Varchar(max) = null,
	@Puestos Varchar(max) = null,
	@IDUsuario int = 1  ,
    @Empleados Varchar(max)  =null
   
)      
AS      
BEGIN     

Declare @dtFiltros [Nomina].[dtFiltrosRH],    
	    @empleadostb [RH].[dtEmpleados],
		@IDDatoExtra_NOMBRE_GAFETE int;


	insert into @dtFiltros(Catalogo,Value)
	values('Departamentos',@Departamentos)
		,('Sucursales',@Sucursales)
		,('Puestos',@Puestos)
        ,('Empleados',@Empleados)

    
	SET @ClaveEmpleadoInicial = CASE WHEN ISNULL(@ClaveEmpleadoInicial,'') = '' THEN '0' ELSE  @ClaveEmpleadoInicial END
	SET @ClaveEmpleadoFinal = CASE WHEN ISNULL(@ClaveEmpleadoFinal,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  @ClaveEmpleadoFinal END 


	select @IDDatoExtra_NOMBRE_GAFETE = IDDatoExtra from [RH].[tblCatDatosExtra] where Nombre = 'NOMBRE_GAFETE'



	IF (@ClaveEmpleadoInicial like '%,%' or @ClaveEmpleadoFinal like '%,%')
	BEGIN 
       insert into @empleadostb    
		Exec [RH].[spBuscarEmpleados] @dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario

		SELECT         
		em.IDEmpleado        
		,em.ClaveEmpleado        
		,em.NOMBRECOMPLETO
		,CASE
			WHEN dex.Valor IS NULL THEN em.Nombre
			ELSE dex.Valor 
		 END AS PrimerNombre
		--,em.SegundoNombre 
		--,em.Nombre as PrimerNombre
		,ISNULL(em.Nombre,'') + ' ' + ISNULL(em.SegundoNombre,'') AS Nombres  
		,em.Paterno        
		,em.Materno  
		,ISNULL(em.Paterno,'') + ' ' + ISNULL(em.Materno,'') AS Apellidos        
		,em.Puesto        
		,em.Departamento        
		,em.Sucursal        
		,em.IMSS      
          ,CAST(mm.Vigente as int) as Vigente
		,em.RFC      
		,em.CURP     
		,em.Empresa     
		,FBE.NombreCompleto NombreEmergencia
		,em.RegPatronal     
        ,reg.RegistroPatronal
		,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono      
		,CASE WHEN SE.TipoSangre IS NULL THEN '' ELSE ('TIPO DE SANGRE: '+SE.TipoSangre) END AS TipoSangre
		,case when FT.ClaveEmpleado IS NULL then (REPLACE(cg.Valor,'Empleados/','nofoto.jpg'))
		else (cg.Valor + em.ClaveEmpleado+'.jpg') END AS Foto
	FROM @empleadostb em  
        LEFT join RH.tblCatRegPatronal reg on reg.IDRegPatronal = em.IDRegPatronal
        inner join RH.tblEmpleadosMaster mm on mm.IDEmpleado =em.IDEmpleado
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
        
			on EM.IDEmpleado = FEU.IDEmpleado
			and FEU.IDUsuario = @IDUsuario  
	--inner join [IMSS].[TblVigenciaEmpleado] V ON V.IDEmpleado = em.idempleado --Agregado solo para que jale los empleados vigentes
	--and V.FechaBaja is null and V.FechaReingreso is null
	left join RH.tblSaludEmpleado SE on EM.IDEmpleado = SE.IDEmpleado
	left join RH.tblFotosEmpleados FT on EM.IDEmpleado = FT.IDEmpleado
	left join RH.TblFamiliaresBenificiariosEmpleados FBE      

		on FBE.IDEmpleado = EM.IDEmpleado      
		and FBE.Emergencia = 1      
		Cross Apply App.tblConfiguracionesGenerales cg 
		inner join [App].[Split](@ClaveEmpleadoFinal,',')fti on fti.item = em.ClaveEmpleado
		inner join [App].[Split](@ClaveEmpleadoInicial,',') ftf on ftf.item = em.ClaveEmpleado
		left join [RH].[tblDatosExtraEmpleados] dex on em.IDEmpleado = dex.IDEmpleado and IDDatoExtra = @IDDatoExtra_NOMBRE_GAFETE

	where --EM.IDEmpleado between @IDEmpleadoIni and @IDEmpleadoFIN     and
		cg.IDConfiguracion = 'PathFotos' and mm.Vigente in (0,1)
		

	
	END
	ELSE 
	BEGIN 
       insert into @empleadostb    
		Exec [RH].[spBuscarEmpleados] @EmpleadoIni = @ClaveEmpleadoInicial,@EmpleadoFin = @ClaveEmpleadoFinal,@dtFiltros = @dtFiltros , @IDUsuario = @IDUsuario
		
		SELECT         
		em.IDEmpleado        
		,em.ClaveEmpleado        
		,em.NOMBRECOMPLETO        
		,CASE
			WHEN dex.Valor IS NULL THEN em.Nombre
			ELSE dex.Valor 
		 END AS PrimerNombre
		--,em.SegundoNombre 
		--,em.Nombre as PrimerNombre     
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
        ,mm.Vigente
		,em.Empresa     
		,FBE.NombreCompleto NombreEmergencia
		,em.RegPatronal     
        ,reg.RegistroPatronal
		,ISNULL(FBE.TelefonoCelular,ISNULL(FBE.TelefonoMovil,'')) Telefono      
		,CASE WHEN SE.TipoSangre IS NULL THEN '' ELSE ('TIPO DE SANGRE: '+SE.TipoSangre) END AS TipoSangre
		,case when FT.ClaveEmpleado IS NULL then (REPLACE(cg.Valor,'Empleados/','nofoto.jpg'))
		else (cg.Valor + em.ClaveEmpleado+'.jpg') END AS Foto
	FROM @empleadostb em  
    LEFT join RH.tblCatRegPatronal reg on reg.IDRegPatronal = em.IDRegPatronal
    inner join RH.tblEmpleadosMaster mm on mm.IDEmpleado =em.IDEmpleado
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios FEU
			on EM.IDEmpleado = FEU.IDEmpleado
			and FEU.IDUsuario = @IDUsuario  
	--inner join [IMSS].[TblVigenciaEmpleado] V ON V.IDEmpleado = em.idempleado --Agregado solo para que jale los empleados vigentes
	--and V.FechaBaja is null and V.FechaReingreso is null
	left join RH.tblSaludEmpleado SE on EM.IDEmpleado = SE.IDEmpleado
	left join RH.tblFotosEmpleados FT on EM.IDEmpleado = FT.IDEmpleado
	left join RH.TblFamiliaresBenificiariosEmpleados FBE      
		on FBE.IDEmpleado = EM.IDEmpleado      
		and FBE.Emergencia = 1      
		Cross Apply App.tblConfiguracionesGenerales cg      
				left join [RH].[tblDatosExtraEmpleados] dex on em.IDEmpleado = dex.IDEmpleado and IDDatoExtra = @IDDatoExtra_NOMBRE_GAFETE

	where --EM.IDEmpleado between @IDEmpleadoIni and @IDEmpleadoFIN     and
		cg.IDConfiguracion = 'PathFotos'  and mm.Vigente in (0,1);

	END

   
END
GO
