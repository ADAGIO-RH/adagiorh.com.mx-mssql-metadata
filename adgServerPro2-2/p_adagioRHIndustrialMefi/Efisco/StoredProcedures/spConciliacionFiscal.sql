USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*    [Efisco].[spConciliacionFiscal] 5    */
CREATE PROCEDURE [Efisco].[spConciliacionFiscal] -- 5
@IDSolicitud int
AS
BEGIN

    if object_id('tempdb..#TempFoliosRepetidos') is not null
                    drop table #TempFoliosRepetidos

    Select 
    e.Folio
    ,cp.Descripcion as PeriodoDeNomina
    ,m.ClaveEmpleado as NumEmpleado
    ,m.NOMBRECOMPLETO as NombreCompleto
    ,CAST(e.FechaTimbrado as DATE) as FechaTimbrado
    ,t.UUID
    ,t.SelloCFDI
    ,e.Estatus
    ,ROW_NUMBER()OVER(Partition by e.Folio order by e.fecha) as RN
    into #TempFoliosRepetidos
    from Facturacion.TblTimbrado t 
        Inner join Nomina.tblHistorialesEmpleadosPeriodos hep on hep.IDHistorialEmpleadoPeriodo = t.IDHistorialEmpleadoPeriodo
        Inner join rh.tblEmpleadosMaster m on hep.IDEmpleado = m.IDEmpleado
        Inner Join Efisco.tblDetallesSolicitudes e on e.Folio = t.IDHistorialEmpleadoPeriodo 
        Inner join Nomina.tblCatPeriodos cp on cp.IDPeriodo = hep.IDPeriodo  
    where 
    Actual = 1 
    and IDEstatusTimbrado = 2 
    and IDSolicitud = @IDSolicitud
    and Estatus = 'VIGENTE'


    Select 
         [Folio]
        ,[PeriodoDeNomina]
        ,[NumEmpleado]
        ,[NombreCompleto]
        ,Utilerias.fnDateToStringByFormat(FechaTimbrado,'FC','Spanish') as FechaTimbrado
        ,[UUID]
        ,[SelloCFDI]
        ,Estatus
    from #TempFoliosRepetidos
    where Folio in (Select Folio from #TempFoliosRepetidos where RN > 1)


END
GO
