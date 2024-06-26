USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Nomina].[spBuscarTablasImpuesto](
     @IDTablaImpuesto int = 0
	 ,@Ejercicio int = 0
) as
begin
    select tp.IDTablaImpuesto
	   ,tp.Ejercicio
	   ,tp.IDPeriodicidadPago
	   ,pp.Descripcion as PeriodicidadPago
	   ,tp.IDCalculo
	   ,tc.Descripcion as TipoCalculo
	   ,tp.Descripcion
    from Nomina.tblTablasImpuestos tp
	   join Sat.tblCatPeriodicidadesPago pp on tp.IDPeriodicidadPago = pp.IDPeriodicidadPago
	   join Nomina.tblCatTipoCalculoISR tc on tp.IDCalculo = tc.IDCalculo
    where (tp.IDTablaImpuesto = @IDTablaImpuesto or @IDTablaImpuesto = 0 )
	and (tp.Ejercicio = @Ejercicio or @Ejercicio = 0 )
    order by tp.Ejercicio desc
end;
GO
