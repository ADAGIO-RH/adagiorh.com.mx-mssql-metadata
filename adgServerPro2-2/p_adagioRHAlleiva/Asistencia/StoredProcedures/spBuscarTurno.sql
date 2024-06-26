USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBuscarTurno](
	@IDTurno int = null 
    ) as
    begin
	   select 
		  ct.IDTurno
		  ,ct.IDTipoJornadaSAT
		  ,UPPER(ctj.Descripcion) as TipoJornadaSAT
		  ,UPPER(ct.Descripcion	) AS Descripcion
		  ,ROW_NUMBER()over(ORDER BY IDTurno)as ROWNUMBER 
	   from [Asistencia].[tblCatTurnos] ct with (nolock)
		  join [Sat].[tblCatTiposJornada] ctj on ct.IDTipoJornadaSAT = ctj.IDTipoJornada
	   where (ct.IDTurno = @IDTurno or @IDTurno is null)
    end;
GO
