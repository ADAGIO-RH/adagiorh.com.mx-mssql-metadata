USE [p_adagioRHEdman]
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
CREATE PROCEDURE [SAP].[MX_EmergencyContactImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

        declare @tempResponse as table (      
            [IDParentesco] int,                                
            [DescripcionIngles] VARCHAR (100)               
        );   
        insert @tempResponse(IDParentesco,DescripcionIngles)
        values 
            (1,'Parent'),
            (2,'Parent'),
            (3,'Spouse'),
            (4,'Child'),
            (5,'Child'),
            (6,'Other')


	select 
		isnull(dd.Valor,e.ClaveEmpleado)[personal-id-external],
		Utilerias.fnEliminarAcentos(fm.NombreCompleto) [name],
		COALESCE(fm.TelefonoCelular,'') [phone],
		COALESCE(fm.TelefonoMovil,'') [second-phone],
		COALESCE(CI.DescripcionIngles,'') [relationship],
		'Y' [primary_flag],
		'' [email],
		'' [operation]

	from rh.tblEmpleadosMaster e
		inner join  RH.tblFamiliaresBenificiariosEmpleados fm on e.IDEmpleado=fm.IDEmpleado
		inner join  RH.tblCatParentescos cf on cf.IDParentesco=fm.IDParentesco
        INNER JOIN @tempResponse CI ON CI.IDParentesco=cf.IDParentesco
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5

END
GO
