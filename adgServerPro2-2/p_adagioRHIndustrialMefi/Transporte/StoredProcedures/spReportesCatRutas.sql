USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-27
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROC [Transporte].[spReportesCatRutas] 
(
    @IDUsuario	int = 0          
) as

	SET FMTONLY OFF;
	 
    select 
        cr.IDRuta,
        cr.ClaveRuta,
        cr.Destino,
        cr.Origen,
        cr.KMRuta,
        cr.Descripcion,
        ch.HoraLlegada [HoraLlegadaRuta],
        ch.HoraSalida [HoraSalidaRuta],
        ah.IDHorario,
        ah.Descripcion [DescripcionHorarioEmpleado]

    From Transporte.tblCatRutas  cr
        left join Transporte.tblCatRutasHorarios ch on ch.IDRuta=cr.IDRuta
        left join Transporte.tblCatRutasHorariosDetalle chd on chd.IDRutaHorario=ch.IDRutaHorario
        left join Asistencia.tblCatHorarios ah on ah.IDHorario=chd.IDHorario
GO
