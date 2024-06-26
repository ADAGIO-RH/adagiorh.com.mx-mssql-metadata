USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Asistencia].[spBuscarHorario](
    @IDHorario int = null
    ,@IDUsuario int
) as

    select ch.IDHorario
	   ,ch.Codigo
	   , isnull(ch.IDTurno,0) as IDTurno
	   , isnull(ct.Descripcion,'Sin turno') as Turno
	   , ch.Descripcion
	   , ch.HoraEntrada
	   , ch.HoraSalida
	   ,ch.TiempoTotal
	   ,ch.TiempoDescanso
	   , ch.JornadaLaboral
    from [Asistencia].[tblCatHorarios] ch with (nolock)
	   join [Asistencia].[tblCatTurnos] ct with (nolock) on ch.IDTurno = ct.IDTurno
    where (ch.IDHorario = @IDHorario or @IDHorario is null)
    order by ch.HoraEntrada asc
GO
