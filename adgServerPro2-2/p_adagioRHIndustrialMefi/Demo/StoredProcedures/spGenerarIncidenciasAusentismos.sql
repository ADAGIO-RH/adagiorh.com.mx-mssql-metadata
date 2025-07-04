USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Demo].[spGenerarIncidenciasAusentismos] (
	@FechaIni date
	,@FechaFin date

)as
BEGIN
declare 
	 @dtEmpleados [RH].[dtEmpleados]
	,@Fechas [App].[dtFechas]
	,@IDEmpleado int
	,@IDUsuarioAdmin int
;

	SET DATEFIRST 7;  
	SET LANGUAGE Spanish;
	SET DATEFORMAT ymd;

	select @IDUsuarioAdmin = cast(Valor as int)
	from  App.tblConfiguracionesGenerales
	where [IDConfiguracion] ='IDUsuarioAdmin'

	if not exists (select top 1 1 from Asistencia.tblCatIncidencias)
	begin
		raiserror('No existen incidencias en la catálogo.',16,1);
		return;
	end;

	declare @tempVigenciaEmpleados table(    
		IDEmpleado int null,    
		Fecha Date null,    
		Vigente bit null		
	); 

	insert into @Fechas
	exec [App].[spListaFechas]@FechaIni,@FechaFin

	insert @dtEmpleados
	exec RH.spBuscarEmpleados @FechaIni = @FechaIni
							  ,@Fechafin = @FechaFin
                            --  ,@EmpleadoIni = '023659'
	                        --  ,@EmpleadoFin  = '023659'
							 ,@IDUsuario = @IDUsuarioAdmin
						 
	insert @tempVigenciaEmpleados
	exec [RH].[spBuscarListaFechasVigenciaEmpleado] @dtEmpleados= @dtEmpleados
													,@Fechas= @Fechas
													,@IDUsuario = @IDUsuarioAdmin

     delete @tempVigenciaEmpleados where (Vigente = 0)

     DELETE Asistencia.tblIncidenciaEmpleado
        where IDIncidencia='D' AND IDEmpleado IN(
            SELECT IDEmpleado FROM @dtEmpleados
        ) AND Fecha BETWEEN @FechaIni and @FechaFin

    if object_id('tempdb..#tempCuandoDescansa') is not null drop table #tempCuandoDescansa;
    if object_id('tempdb..#tempDiaDescanso') is not null drop table #tempDiaDescanso;
---DescansoEntreSemana=0 Descansa en Fin de Semana
---DescansoEntreSemana=1 Descansa Entre Semana

    SELECT E.IDEmpleado
           ,CASE WHEN ((ABS(CHECKSUM(NEWID(), IDEmpleado)) % 10) + 1)>2 THEN 0 ELSE 1 END as DescansoEntreSemana            
    INTO #tempCuandoDescansa
    FROM @dtEmpleados E

    SELECT datos.IDEmpleado
           ,Datos.DescansoEntreSemana
           ,CASE WHEN Datos.DescansoEntreSemana=0 THEN (ABS(CHECKSUM(NEWID())) % 2) * 6 + 1 ELSE (ABS(CHECKSUM(NEWID(), IDEmpleado)) % 5) + 2 END AS DP
    INTO #tempDiaDescanso
    FROM #tempCuandoDescansa Datos

            print('Elimino las fechas que no son descansos')
            delete ve 
            from  @tempVigenciaEmpleados  ve 
            INNER JOIN #tempDiaDescanso D
                ON D.IDEmpleado = ve.IDEmpleado
            WHERE DATEPART(DW,Fecha)<>D.DP


            print('ESTOY INSERTANDO LOS DESCANSOS')

            INSERT INTO Asistencia.tblIncidenciaEmpleado
            (
                IDEmpleado
                ,IDIncidencia
                ,Fecha
                ,TiempoSugerido
                ,TiempoAutorizado
                ,Comentario
                ,CreadoPorIDUsuario
                ,Autorizado
                ,AutorizadoPor
                ,FechaHoraAutorizacion
                ,FechaHoraCreacion
                ,IDIncapacidadEmpleado
                ,ComentarioTextoPlano
                ,HorarioAD
                ,IDHorario
                ,Entrada
                ,Salida
            )
            SELECT 
            VE.IDEmpleado AS IDEmpleado
            ,'D' AS [IDIncidencia]
            ,VE.Fecha AS Fecha
            ,NULL AS [TiempoSugerido]
            ,NULL AS [TiempoAutorizado]
            ,'Descanso generado por servicio demo' AS [Comentario]
            ,@IDUsuarioAdmin AS [CreadoPorIDUsuario]
            ,1 AS [Autorizado]
            ,1 AS [AutorizadoPor]
            ,GETDATE() AS [FechaHoraAutorizacion]
            ,GETDATE() AS [FechaHoraCreacion]
            ,NULL AS [IDIncapacidadEmpleado]
            ,'Descanso generado por servicio demo' AS [ComentarioTextoPlano]            
            ,NULL AS [HorarioAD]
            ,NULL AS [IDHorario]
            ,NULL AS [Entrada]
            ,NULL AS [Salida]
            
            FROM @tempVigenciaEmpleados ve
            INNER JOIN #tempDiaDescanso D
                ON D.IDEmpleado = ve.IDEmpleado


END
GO
