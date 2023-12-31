USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spReporteSolicitudesVacacionesRD] --577, 99, 1     
(  
  @ClaveEmpleado VARCHAR(10),      
  @Empleados int,        
  @IDUsuario int,
  @Fechaini date,
  @FechaFin date
)      
AS      
BEGIN      
       
	DECLARE       
	   @empleadosM [RH].[dtEmpleados]          
	  ,@dtFiltros [Nomina].[dtFiltrosRH]  
	  ,@CantidadDias int
	  ,@CantidadDescansos int

       
      
   if(isnull(@Empleados,'')<>'')      
   BEGIN      
	   insert into @dtFiltros(Catalogo,Value)      
	   values('Empleados',case when @Empleados is null then '' else @Empleados end)      
   END
   ELSE
   BEGIN
	   Select @Empleados = IDEmpleado from rh.tblEmpleadosMaster where ClaveEmpleado = @ClaveEmpleado
	   insert into @dtFiltros(Catalogo,Value)      
	   values('Empleados',case when @Empleados is null then '' else @Empleados end)
   END     

 --  if not exists (select * from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'V' and Fecha = @Fechaini and IDEmpleado = @Empleados )
	--begin
	--	raiserror('No existen esta incidencia en calendario', 16,1)
	--	return
	--end  

	--if not exists (select * from Asistencia.tblIncidenciaEmpleado where IDIncidencia = 'V' and Fecha = @FechaFin and IDEmpleado = @Empleados )
	--begin
	--	raiserror('No existen esta incidencia en calendario', 16,1)
	--	return
	--end 
	
	insert into @empleadosM      
    exec [RH].[spBuscarEmpleadosMaster]@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario   

	Select @CantidadDias = count(*) from Asistencia.tblIncidenciaEmpleado where Fecha between @Fechaini and @FechaFin and IDIncidencia = 'V' and IDEmpleado = @Empleados 

	DECLARE @TempValores AS TABLE 
	(ID INT NOT NULL PRIMARY KEY,
	 FechaIni INT NOT NULL
	 
	 )

 
	select @Fechaini as FechaIni,
			@FechaFin as FechaFin,
			(@CantidadDias+1) as CantidadDias,
			DATEADD(day,1,@FechaFin) as FechaReingreso
			,@Empleados as IdEmpleado
			--union all
			--select ie.Fechaini as FechaIniSolicitudes,
			--	   ie.FechaFin as FechaFinSolicitudes,
			--	   ie.CantidadDias as CantidadDiasSolicitudes,
			--	   DATEADD(day,1,ie.FechaFin) as ReingresoSolicitudes,
			--	   ie.IDEmpleado as EmpeladoSolicitudes
			--from Intranet.tblSolicitudesEmpleado ie with(nolock)
			--where ie.IDEmpleado = @Empleados
	--) as x
		

END
GO
