USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarAgentesCapacitacion] --4  
(    
 @IDAgenteCapacitacion int = null    
)    
AS    
BEGIN    
	SELECT A.IDAgenteCapacitacion,    
		ISNULL(UPPER(A.Codigo),'') as Codigo,    
		ISNULL(A.IDTipoAgente,0) as IDTipoAgente,    
		ISNULL(UPPER(TA.Descripcion),'') as TipoAgente,    
		ISNULL(UPPER(A.Nombre),'') as Nombre,    
		ISNULL(UPPER(A.Apellidos),'') as Apellidos,    
		ISNULL(UPPER(A.RFC),'') as RFC,    
		ISNULL(UPPER(A.RegistroSTPS),'') as RegistroSTPS,    
		ISNULL(UPPER(A.Contacto),'') as Contacto,    
		UPPER(COALESCE(A.RFC,'')+' - '+COALESCE(A.Nombre,'')+' '+COALESCE(A.Apellidos,'')) AS AgenteCapacitacionFull ,    
		ROW_NUMBER()OVER(ORDER BY A.IDAgenteCapacitacion) as ROWNUMBER    
	FROM STPS.tblAgentesCapacitacion A with (nolock)    
		inner join STPS.tblCatTiposAgentes TA with (nolock)   
			on TA.IDTipoAgente = A.IDTipoAgente    
	WHERE ((A.IDAgenteCapacitacion = @IDAgenteCapacitacion) or (isnull(@IDAgenteCapacitacion,0) = 0))    
END;
GO
