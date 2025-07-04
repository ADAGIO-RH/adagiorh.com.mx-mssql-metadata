USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Asistencia].[spCalcularJornadaTiempoTotal](
     @HoraEntrada	time
    ,@HoraSalida	time
    ,@TiempoDescanso	time
) as
BEGIN
    declare @JornadaLaboral time
		 ,@TiempoTotal	time;
    
    --set @TiempoTotal = convert(time, convert(datetime,convert(float,convert(datetime,@f)) - convert(float,convert(datetime,@d))))

    set @TiempoTotal = [Utilerias].[fsRedondeaTime](convert(time,convert(datetime, convert(float,convert(datetime,@HoraSalida)) - convert(float,convert(datetime,@HoraEntrada)))))

    set @JornadaLaboral = [Utilerias].[fsRedondeaTime](convert(time,convert(datetime, convert(float,convert(datetime,@TiempoTotal)) - convert(float,convert(datetime,@TiempoDescanso)))))

    select @JornadaLaboral as JornadaLaboral, @TiempoTotal as TiempoTotal
END;
GO
