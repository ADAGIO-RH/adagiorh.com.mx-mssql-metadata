USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*  
   Esta funcion tiene como proposito cambiar los siguientes caracteres
   Ñ por N
   Quitar acentos
   CONVIERTE EN MAYUSCULAS
   NO HE PODIDO VER PORQUE REVUELVE MAYUSCULAS Y MINUSCULAS
*/  
CREATE function [Utilerias].[fnCleanString](  
    @Cadena nvarchar(max)  
) returns nvarchar(max)  
as  
BEGIN  
    return ISNULL(UPPER(TRANSLATE(@Cadena,'ñáéíóúàèìòùãõâêîôôäëïöüçÑÁÉÍÓÚÀÈÌÒÙÃÕÂÊÎÔÛÄËÏÖÜÇ','naeiouaeiouaoaeiooaeioucNAEIOUAEIOUAOAEIOOAEIOUC')),'')             
END
GO
