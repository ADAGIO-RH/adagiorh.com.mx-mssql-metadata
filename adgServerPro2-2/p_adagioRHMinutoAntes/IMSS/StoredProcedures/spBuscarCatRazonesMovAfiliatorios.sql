USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBuscarCatRazonesMovAfiliatorios]
(
    @IDTipoMovimiento int = null
)
AS
BEGIN
    if (@IDTipoMovimiento is null)
    begin
	    SELECT 
		    IDRazonMovimiento
		    ,Codigo
		    ,Descripcion
		    ,Alta
		    ,Baja
		    ,ReIngreso
		    ,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
	    FROM IMSS.tblCatRazonesMovAfiliatorios
    end;

    if (@IDTipoMovimiento  = 1)
    begin
	    SELECT 
		    IDRazonMovimiento
		    ,Codigo
		    ,Descripcion
		    ,Alta
		    ,Baja
		    ,ReIngreso
		    ,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
	    FROM IMSS.tblCatRazonesMovAfiliatorios
	    WHERE Alta=1
    end;

    if (@IDTipoMovimiento  = 2)
    begin
	    SELECT 
		    IDRazonMovimiento
		    ,Codigo
		    ,Descripcion
		    ,Alta
		    ,Baja
		    ,ReIngreso
		    ,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
	    FROM IMSS.tblCatRazonesMovAfiliatorios
	    WHERE Baja=1
    end;

    if (@IDTipoMovimiento  = 3)
    begin
	    SELECT 
		    IDRazonMovimiento
		    ,Codigo
		    ,Descripcion
		    ,Alta
		    ,Baja
		    ,ReIngreso
		    ,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
	    FROM IMSS.tblCatRazonesMovAfiliatorios
	    WHERE ReIngreso=1 
    end;

    if (@IDTipoMovimiento  = 4)
    begin
	    SELECT 
		    IDRazonMovimiento
		    ,Codigo
		    ,Descripcion
		    ,Alta
		    ,Baja
		    ,ReIngreso
		    ,MovSueldo
			,ROW_NUMBER()over(ORDER BY IDRazonMovimiento)as ROWNUMBER 
	    FROM IMSS.tblCatRazonesMovAfiliatorios
	    WHERE MovSueldo=1 
    end;

END
GO
