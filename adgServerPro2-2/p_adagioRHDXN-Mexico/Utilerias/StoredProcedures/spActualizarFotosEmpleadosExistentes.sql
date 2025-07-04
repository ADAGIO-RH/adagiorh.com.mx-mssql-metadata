USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Utilerias].[spActualizarFotosEmpleadosExistentes]
	@stringArchivos VARCHAR(MAX) = ''
AS
BEGIN

   IF OBJECT_ID('tempdb..#TempMatchFoto') IS NOT NULL DROP TABLE #TempMatchFoto  ;


select * 
	into #TempMatchFoto
from [App].[Split](@stringArchivos,',') s
	left join [RH].[tblFotosEmpleados] t
		on s.item = t.ClaveEmpleado
	WHERE t.IDEmpleado is not null 

	MERGE [RH].[tblFotosEmpleados]  T
	USING #TempMatchFoto S 
		ON T.ClaveEmpleado = S.Item
	
	WHEN NOT MATCHED BY TARGET AND EXISTS (SELECT 1 FROM RH.tblEmpleados WHERE ClaveEmpleado = S.Item) THEN
	INSERT (ClaveEmpleado,IDEmpleado) VALUES (S.Item,(select IDEmpleado from RH.tblEmpleados where ClaveEmpleado = S.Item))

	WHEN NOT MATCHED BY SOURCE 
	THEN 
	DELETE;

	

END
GO
