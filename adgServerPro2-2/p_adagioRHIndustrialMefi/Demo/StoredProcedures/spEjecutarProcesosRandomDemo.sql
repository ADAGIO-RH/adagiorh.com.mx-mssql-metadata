USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Demo].[spEjecutarProcesosRandomDemo] as
BEGIN
	declare 
		@FechaIni date  
		,@FechaFin date  
        ,@FechaHoy date =GETDATE()
        -- ,@FechaHoy date ='2023-04-01'
		,@Mes int=0
        ,@Ejercicio int=0
        ,@IDUsuarioAdmin int
	;

    print('INICIA PROCESO DEMO')    
    SET @Mes=DATEPART(MONTH,@FechaHoy)
    SET @Ejercicio=DATEPART(Year,@FechaHoy)


    
    select @FechaIni = min(DATEADD(month,@Mes-1,DATEADD(year,@Ejercicio-1900,0)))   
		, @FechaFin=MAX(DATEADD(day,-1,DATEADD(month,@Mes,DATEADD(year,@Ejercicio-1900,0))))   


	select @IDUsuarioAdmin = cast(Valor as int)
	from  App.tblConfiguracionesGenerales
	where [IDConfiguracion] ='IDUsuarioAdmin'

	insert Demo.tblLogActividades(Error,Mensaje)
	select 0,'Inicia Proceso DEMO '+cast(getdate() as varchar)

    -- [Demo].[spSimularRotacionPersonal]
    -- [Demo].[spGenerarIncidenciasAusentismos]
    --[Demo].[spAsignarHorarioChecadas] 


    begin try
		print('INICIA SIMULACION DE ROTACION')    
        insert Demo.tblLogActividades(Error,Mensaje)
		select 0,'Ejecuta [Demo].[spSimularRotacionPersonal]'+cast(getdate() as varchar)
		exec [Demo].[spSimularRotacionPersonal] @Fechaini = @Fechaini, @FechaFin = @FechaFin
	end try
	begin catch
		exec Demo.spGetErrorInfo 
	end catch


	begin try
		print('INICIA INCIDENCIAS AUSENTISMOS')    
        insert Demo.tblLogActividades(Error,Mensaje)
		select 0,'Ejecuta [Demo].[spGenerarIncidenciasAusentismos]'+cast(getdate() as varchar)
		exec [Demo].[spGenerarIncidenciasAusentismos] @Fechaini = @Fechaini, @FechaFin = @FechaFin
	end try
	begin catch
		exec Demo.spGetErrorInfo 
	end catch


    begin try
    print('INICIA PROCESO DE CHECADAS HORARIOS')    
		insert Demo.tblLogActividades(Error,Mensaje)
		select 0,'Ejecuta [Demo].[spAsignarHorarioChecadas]'+cast(getdate() as varchar)
		exec [Demo].[spAsignarHorarioChecadas] @Fechaini = @Fechaini, @FechaFin = @FechaFin
	end try
	begin catch
		exec Demo.spGetErrorInfo 
	end catch
END
GO
