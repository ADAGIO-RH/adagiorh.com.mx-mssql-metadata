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
CREATE PROC [Transporte].[spReportesCatVehiculos] 
(
    @IDUsuario	int = 0          
) as

	SET FMTONLY OFF;
	 
    
    select 
    v.IDVehiculo,
    v.ClaveVehiculo,    
    v.NumeroEconomico,
    cm.IDMarcaVehiculo,
    cm.Descripcion [Marca],

    ccc.IDTipoCosto,
    ccc.Descripcion [TipoCosto],

    ctv.IDTipoVehiculo,
    ctv.Descripcion [TipoVehiculo],
    
    ctc.IDTipoCombustible,
    ctc.Descripcion [TipoCombustible],
    v.CostoUnidad,
    v.CantidadPasajeros,
    v.Status    
    from Transporte.tblCatVehiculos AS v
    inner join Transporte.tblCatTipoCombustible ctc on ctc.IDTipoCombustible=v.IDTipoCombustible
    inner join Transporte.tblCatTipoVehiculo ctv on ctv.IDTipoVehiculo=v.IDTipoVehiculo
    inner join Transporte.tblCatTipoCosto ccc on ccc.IDTipoCosto=v.IDTipoCosto
    inner join Transporte.tblCatMarcaVehiculos cm on cm.IDMarcaVehiculo=v.IDMarcaVehiculo
     
    where [Status]=1
    order by v.ClaveVehiculo
GO
