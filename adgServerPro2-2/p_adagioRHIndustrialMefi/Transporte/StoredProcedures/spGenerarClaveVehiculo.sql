USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Generar las claves de los vehiculos.
** Autor			: Jose Miguel Vargas Hernandez
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-02-23
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROCEDURE [Transporte].[spGenerarClaveVehiculo] -- 4,0,1  
(      
    @IDUsuario int   =null
)  
AS  
BEGIN  

	DECLARE @LongitudNoNomina int,  
		@Prefijo varchar(10),  		
        @CalcularStringClave int,  		
		@ClaveVehiculo Varchar(20) ,
        @MAXClaveID INT
	;  
    set @Prefijo='VEH'
    set @LongitudNoNomina=7
  
    select @MAXClaveID = isnull(MAX(cast(REPLACE(E.ClaveVehiculo, isnull(@Prefijo,''),'') as int)),0)  
    from Transporte.tblCatVehiculos E  with(nolock)   
            
    Set @MAXClaveID = @MAXClaveID + 1  
    set @CalcularStringClave = @LongitudNoNomina - LEN(isnull(@Prefijo,''))  
		 
	SELECT @ClaveVehiculo = isnull(@Prefijo,'')+REPLICATE('0',@CalcularStringClave - LEN(RTRIM(cast( @MAXClaveID as varchar)))) + cast( @MAXClaveID as Varchar)  
  
	Select @ClaveVehiculo as ClaveVehiculo  
END
GO
