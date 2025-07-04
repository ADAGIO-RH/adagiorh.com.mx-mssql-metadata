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
CREATE PROCEDURE [Transporte].[spGenerarClaveRuta] -- 4,0,1  
(      
    @IDUsuario int   =null
)  
AS  
BEGIN  

	DECLARE @LongitudNoNomina int,  
		@Prefijo varchar(10),  		
        @CalcularStringClave int,  		
		@ClaveRuta Varchar(20) ,
        @MAXClaveID INT
	;  
    set @Prefijo='RUT'
    set @LongitudNoNomina=7
  
  
    select @MAXClaveID = isnull(MAX(cast(REPLACE(E.ClaveRuta, isnull(@Prefijo,''),'') as int)),0)  
    from Transporte.tblCatRutas E  with(nolock)   
            
    Set @MAXClaveID = @MAXClaveID + 1  
    set @CalcularStringClave = @LongitudNoNomina - LEN(isnull(@Prefijo,''))  
		 
	SELECT @ClaveRuta = isnull(@Prefijo,'')+REPLICATE('0',@CalcularStringClave - LEN(RTRIM(cast( @MAXClaveID as varchar)))) + cast( @MAXClaveID as Varchar)  
  
	Select @ClaveRuta as ClaveRuta
END
GO
