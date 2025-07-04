USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Buscar datos de saludo del colaborador  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2018-06-11  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
2018-06-20  Jose Roman      Se agregan Campos de IMC Categoria y Tratamiento de Alergias  
***************************************************************************************************/  
CREATE proc [RH].[spBuscarSaludEmpleado](  
    @IDSaludEmpleado int = 0  
    ,@IDEmpleado int = 0  
)  as  
      
    select   
		IDSaludEmpleado  
		,IDEmpleado  
		,TipoSangre  
		,isnull(Estatura,0) as Estatura  
		,isnull(Peso,0) as Peso  
		,isnull(IMC ,0) as  IMC  
		,isnull(IMCC ,'') as  IMCC  
		,Alergias  
		,TratamientoAlergias 
		,isnull(RequiereTarjetaSalud,0) as RequiereTarjetaSalud
		,isnull(VencimientoTarjeta,'1900-01-01') as VencimientoTarjeta
    from [RH].[tblSaludEmpleado] with (nolock)  
    where (IDSaludEmpleado = @IDSaludEmpleado) or (IDEmpleado = @IDEmpleado)
GO
