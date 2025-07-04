USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar listado de alergias
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-06-11
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-07-11		Aneudy Abreu		Agregue el coalesce(Alergias,''), por esta razón la lista salía vacía
***************************************************************************************************/
CREATE proc [RH].[spBuscarAlergias]
as 
    Declare @val Varchar(MAX);
    Select @val = COALESCE(@val + ',' + coalesce(Alergias,''), Alergias) From RH.tblSaludEmpleado WITH (NOLOCK)

    Select DISTINCT upper(item) as Alergia
    from app.Split(@val,',');
GO
