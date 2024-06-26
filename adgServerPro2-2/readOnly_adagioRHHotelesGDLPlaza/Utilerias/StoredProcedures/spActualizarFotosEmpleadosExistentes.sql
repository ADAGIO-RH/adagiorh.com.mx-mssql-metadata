USE [readOnly_adagioRHHotelesGDLPlaza]
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

	MERGE [RH].[tblFotosEmpleados]  T
	USING [App].[Split](@stringArchivos,',') S ON T.ClaveEmpleado = S.Item
	
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (ClaveEmpleado,IDEmpleado) VALUES (S.Item,(select IDEmpleado from RH.tblEmpleados where ClaveEmpleado = S.Item))

	WHEN NOT MATCHED BY SOURCE 
	THEN 
	DELETE;

	

END
GO
