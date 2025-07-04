USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Utilerias].[spTablaInversa] as

DECLARE 
@Peridicidad varchar(max) = 'Anual',
@NombreTabla VARCHAR(max) = 'ISR ANUAL 2023',
@IDTABALIMPUESTO INT ,
@IDTablaInverso int = 0


set @IDTABALIMPUESTO =  (Select IDTablaImpuesto from Nomina.tblTablasImpuestos where Descripcion = @NombreTabla and Ejercicio = 2023)

IF NOT EXISTS (Select * from nomina.tblDetalleTablasImpuestos where IDTablaImpuesto = @IDTABALIMPUESTO)
BEGIN
print 'No existe Tabla para generar su inversa'
return
END

INSERT INTO Nomina.tblTablasImpuestos
Select 
(SELECT IDPeriodicidadPago FROM SAT.tblCatPeriodicidadesPago WHERE Descripcion=@Peridicidad),
(Select DATEPART(year,getdate())),
(Select IDCalculo from nomina.tblCatTipoCalculoISR where Codigo = 'ISR_INVERSO'),
CONCAT(@NombreTabla,' INVERSO '),
(Select IDPais FROM SAT.tblCatPaises WHERE Codigo='MEX')
SET @IDTablaInverso=@@IDENTITY


insert into Nomina.tblDetalleTablasImpuestos
Select
@IDTablaInverso, 
[LimiteInferior],

case when [LimiteSuperior] is null then 999999999.0000 
                                   else LimiteSuperior end 
                                   as LimiteSuperior,

CASE WHEN LAG(CuotaFija) OVER (ORDER BY LimiteInferior) IS NULL THEN 0 
                                                                ELSE LAG(CuotaFija) OVER (ORDER BY LimiteInferior) END 
                                                                AS CuotaFija,
[Porcentaje] 
from 
    ( Select 
     LimiteInferior - CoutaFija as limiteInferior
    ,LimiteSuperior - LEAD(CoutaFija) OVER(ORDER BY CoutaFija) as LimiteSuperior
    ,LimiteSuperior as CuotaFija 
    ,1 - Porcentaje as Porcentaje
    from Nomina.tblDetalleTablasImpuestos 
    where IDTablaImpuesto = @IDTABALIMPUESTO ) a
GO
