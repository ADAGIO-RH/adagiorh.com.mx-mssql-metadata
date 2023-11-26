USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spBuscarNombresTabuladorSalarial]  as
     
	select 
		distinct isnull(Nombre,'-- Sin Nombre --') as Nombre
    
	from RH.tblTabuladorSalarial  
	order by Nombre asc
GO
