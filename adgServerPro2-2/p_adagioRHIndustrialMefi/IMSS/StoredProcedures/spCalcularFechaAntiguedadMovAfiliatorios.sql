USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Calcula la fecha de antiguedad y IDTipoPrestacion en la tabla de IMSS.tblMovAfiliatorios
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-11
** Paremetros		:   
				    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
 ***************************************************************************************************/
CREATE PROCEDURE [IMSS].[spCalcularFechaAntiguedadMovAfiliatorios](
	@IDEmpleado int = 0,
	@IDMovAfiliatorio int = 0
)
AS
BEGIN
    update  M 
    set M.FechaAntiguedad  =(select MAX( Fecha)             
					from [IMSS].[tblMovAfiliatorios]  mReingresoAnt WITH(NOLOCK)            
				join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingresoAnt.IDTipoMovimiento=c.IDTipoMovimiento            
					where mReingresoAnt.IDEmpleado=m.IDEmpleado and c.Codigo in ('A','R')
				and mReingresoAnt.Fecha <= M.Fecha  
				and isnull(mReingresoAnt.RespetarAntiguedad,0) <> 1				
            ),
            m.IDTipoPrestacion= (select IDTipoPrestacion from [RH].[TblPrestacionesEmpleado] Prestaciones WITH(NOLOCK) 
                    where  Prestaciones.IDEmpleado = M.IDEmpleado  AND Prestaciones.FechaIni<= M.Fecha  AND Prestaciones.FechaFin >= M.Fecha        )
    from IMSS.tblMovAfiliatorios M
    where IDEmpleado=@IDEmpleado OR IDMovAfiliatorio=@IDMovAfiliatorio

END
GO
