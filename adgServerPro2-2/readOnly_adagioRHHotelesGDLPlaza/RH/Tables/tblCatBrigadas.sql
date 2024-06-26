USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatBrigadas](
	[IDBrigada] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [App].[XLDescription] NOT NULL,
 CONSTRAINT [PK_RHTblCatBrigadas_IDBrigada] PRIMARY KEY CLUSTERED 
(
	[IDBrigada] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
