USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Asistencia].[spBuscarHorario](
    @IDHorario int = null
    ,@IDUsuario int
) AS


	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;


   DECLARE @TieneFiltros int = 0;

	SELECT DGH.IDHorario
	INTO #TempFiltros  
	FROM Seguridad.tblFiltrosUsuarios FU  WITH(NOLOCK) 
        INNER JOIN Asistencia.tblCatGruposHorarios GH
            ON GH.IDGrupoHorario = FU.ID
        INNER JOIN Asistencia.tblDetalleGrupoHorario DGH
            ON DGH.IDGrupoHorario = GH.IDGrupoHorario
	WHERE IDUsuario = @IDUsuario AND Filtro = 'GruposHorarios'  


    SELECT @TieneFiltros=COUNT(*) FROM #TempFiltros  


    SELECT 
        ch.IDHorario
	   ,ch.Codigo
	   , isnull(ch.IDTurno,0) as IDTurno
	   , isnull(ct.Descripcion,'Sin turno') as Turno
	   , ch.Descripcion
	   , ch.HoraEntrada
	   , ch.HoraSalida
	   ,ch.TiempoTotal
	   ,ch.TiempoDescanso
	   , ch.JornadaLaboral
    FROM [Asistencia].[tblCatHorarios] ch WITH (NOLOCK)
	   JOIN [Asistencia].[tblCatTurnos] ct WITH (nolock) on ch.IDTurno = ct.IDTurno       
    WHERE (ch.IDHorario = @IDHorario OR @IDHorario IS NULL)
      AND (@TieneFiltros = 0 OR  ch.IDHorario IN (SELECT IDHorario FROM #TempFiltros) )
    ORDER BY ch.HoraEntrada ASC
GO
