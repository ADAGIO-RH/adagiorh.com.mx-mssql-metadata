USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Buscar datos de SUBSIDIO del colaborador    
** Autor   : Jose Roman   
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2024-05-02    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
0000-00-00  NombreCompleto  ¿Qué cambió?    
 
***************************************************************************************************/    
CREATE proc [RH].[spBuscarSubsidioEmpleado] --0, 126

(    
    @IDSubsidioEmpleado int = 0    
    ,@IDEmpleado int = 0    
)  as    
      
	if exists(select * from [Nomina].[TblSubsidioEmpleado] with(NOLOCK) where IDEmpleado = @IDEmpleado)
	BEGIN
		select     
			ISNULL(IDSubsidioEmpleado,0) as IDSubsidioEmpleado,
			ISNULL(IDEmpleado, @IDEmpleado) as IDEmpleado,
			cast(ISNULL(Subsidio,0) as bit) as Subsidio
		from [Nomina].[TblSubsidioEmpleado] with(NOLOCK)   
		where (IDSubsidioEmpleado = @IDSubsidioEmpleado) 
			or     
			(IDEmpleado = @IDEmpleado)  
	END
	ELSE
	BEGIN
		select     
		ISNULL(0,0) as IDSubsidioEmpleado,
		ISNULL(@IDEmpleado, @IDEmpleado) as IDEmpleado,
		cast(0 as bit) as Subsidio
	END
GO
