USE [p_adagioRHSurfax]
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
CREATE PROCEDURE [SAP].[MX_PersonInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

    -- CAMBIO PARA OBTENER SOLAMENTE LOS CLIENTES DE RUGGEDTECH -- 28 JULIO 2023
    declare @IDClienteRuggedtech  INT  ;
    set @IDClienteRuggedtech =1;
    

	select 
		isnull(dd.Valor,e.ClaveEmpleado) [user-id],  
		convert(varchar, e.FechaNacimiento , 101) [date-of-birth] ,
		isnull(dd.Valor,e.ClaveEmpleado) [person-id-external] 
	from RH.tblEmpleadosMaster  as e
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
		left join Seguridad.tblUsuarios u on u.IDEmpleado=e.IDEmpleado
    where e.Vigente=1 and e.IDCliente=@IDClienteRuggedtech
END
GO
