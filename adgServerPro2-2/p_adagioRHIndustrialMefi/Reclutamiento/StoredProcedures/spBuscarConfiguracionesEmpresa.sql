USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**************************************************************************************************** 
** Descripción		: Buscar configuraciones de la empresa en reclutamiento
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-09-25
** Paremetros		:              

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spBuscarConfiguracionesEmpresa]    
(    
    @IDConfiguracion varchar(255) =null
)    
AS    
BEGIN    

	select IDConfiguracion,Descripcion,Valor  From Reclutamiento.tblConfiguacionesEmpresa
END
GO
