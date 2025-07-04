USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /**************************************************************************************************** 
** Descripción		: Buscar el varlo máximo del campo OrdenCalculo en la tabla de [Nomina].[tblCatConceptos]
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
Create PROC [Nomina].[MaxOrdenCalculo]
as
select isnull(max(OrdenCalculo),0) + 1 as OrdenCalculo
from [Nomina].[tblCatConceptos]
GO
