USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tareas].[tblCatEstatusTareas](
	[IDEstatusTarea] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoTablero] [int] NULL,
	[IDReferencia] [int] NULL,
	[Icon] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Titulo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Orden] [int] NULL,
	[IsDefault] [bit] NULL,
	[IsEnd] [bit] NULL,
 CONSTRAINT [Pk_TareasTblCatEstatusTareas_IDEstatusTarea] PRIMARY KEY CLUSTERED 
(
	[IDEstatusTarea] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
