USE [p_adagioRHIndustrialMefi]
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
	   ,ISNULL(tp.IDPais,0) as IDPais
	   ,P.Descripcion as Pais
    from Nomina.tblTablasImpuestos tp With(Nolock)
	   join Sat.tblCatPeriodicidadesPago pp With(Nolock) 
			on tp.IDPeriodicidadPago = pp.IDPeriodicidadPago
	   join Nomina.tblCatTipoCalculoISR tc With(Nolock)  
			on tp.IDCalculo = tc.IDCalculo
	   left Join SAT.tblCatPaises P With(Nolock) 	
			on tp.IDPais = p.IDPais
    where (tp.IDTablaImpuesto = @IDTablaImpuesto or @IDTablaImpuesto = 0 )
		and (tp.Ejercicio = @Ejercicio or @Ejercicio = 0 )
    order by tp.Ejercicio desc
end;
GO
