USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	Importación a SAP
-- =============================================
CREATE PROCEDURE [SAP].[MX_AddressImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
    -- CAMBIO PARA OBTENER SOLAMENTE LOS CLIENTES DE RUGGEDTECH -- 28 JULIO 2023
    declare @IDClienteRuggedtech  INT  ;
    set @IDClienteRuggedtech =1;
    
	select 
		--e.ClaveEmpleado [person-id-external],
        isnull(dd.Valor,e.ClaveEmpleado) as [person-id-external],
         convert(varchar, de.FechaIni , 101) [start-date],
         '' [end-date],
		--case de.FechaFin  when  '9999-12-31' then ''  Else convert(varchar, de.FechaFin , 101) end [end-date],
		Utilerias.fnEliminarAcentos(concat(de.Calle,' ',COALESCE(de.Exterior,''),COALESCE(de.Interior,''))) [address1],
		'' [address2],
        Utilerias.fnEliminarAcentos(COALESCE(de.[Colonia],'')) [address3],
	    Utilerias.fnEliminarAcentos(COALESCE(de.Municipio,'')) [city],
	    '' [county],
	    [Utilerias].[fnCapitalize](Utilerias.fnEliminarAcentos(COALESCE(de.[Estado],'')))  [state],
	    '' [province],
	    Utilerias.fnEliminarAcentos(COALESCE(de.[CodigoPostal],'')) [zip-code],
	    Utilerias.fnEliminarAcentos(COALESCE(cp.[Codigo],'')) [country],
	    '' [notes],
	    '' [address4],
	    '' [address5],
	    'home' [address-type],
	    '' [operation]
	from RH.tblEmpleadosMaster e
		left join RH.tblDireccionEmpleado de on de.IDEmpleado =e.IDEmpleado
		inner join Sat.tblCatPaises cp on cp.IDPais=de.IDPais
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
    where  e.Vigente=1 and IDCliente=@IDClienteRuggedtech
END
GO
