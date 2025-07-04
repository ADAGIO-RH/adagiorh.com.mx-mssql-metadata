USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**************************************************************************************************** 
** Descripción		: Actualizar configuraciones de la empresa en reclutamiento
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-09-25
** Paremetros		:              

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spIUConfiguracionesEmpresa]    
(    
    @IDConfiguracion varchar(255) =null,
    @Descripcion varchar(255) =null,
    @Valor nvarchar(max) =null,
    @IDUsuario int
)
AS    
BEGIN    

    if isnull(@IDConfiguracion,'') <>'' 
    begin 
        update Reclutamiento.tblConfiguacionesEmpresa set Valor=@Valor WHERE IDConfiguracion=@IDConfiguracion

        -- select IDConfiguracion,Descripcion,Valor  From Reclutamiento.tblConfiguacionesEmpresa
    end
	
END
GO
